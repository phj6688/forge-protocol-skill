# NullDrift Signal Engine -- TASKSPEC

## Provenance
| Field | Value |
|-------|-------|
| Date | 2026-04-02 |
| Codebase | greenfield |
| Spec Version | v1.0 |

## Mission
Autonomous crypto signal engine running GPU-accelerated sentiment analysis on homelab. Paper trades 20 strategies in a Darwinian tournament, publishes results to Telegram/X under @NullDrift_ai. Proves signal quality through calibration logging before real capital.

## Stack
| Layer | Technology | Version | Rationale |
|-------|-----------|---------|-----------|
| Runtime | Python | 3.11+ | Homelab standard, GPU libs |
| Inference | Ollama | latest | ROCm GPU, Mistral-7B + Phi-3-mini |
| Database | PostgreSQL 16 | pgvector | Shared platform-postgres, vector search |
| Cache | Redis 7 | latest | Signal TTL cache, strategy state |
| Scheduling | APScheduler | 3.x | Cron-like in-process |
| API Data | CoinGecko + RSS | free tier | Price + news feeds |
| Messaging | python-telegram-bot | 20.x | Channel publishing |

## Directory Structure

```
nulldrift-engine/
├── src/
│   ├── __init__.py
│   ├── main.py                    # entry point, scheduler
│   ├── signals/
│   │   ├── __init__.py
│   │   ├── fast_lane.py           # 15-min Phi-3-mini sentiment
│   │   ├── deep_lane.py           # 1-hour Mistral-7B analysis
│   │   └── aggregator.py          # composite signal
│   ├── strategy/
│   │   ├── __init__.py
│   │   ├── tournament.py          # 20-strategy tournament
│   │   ├── fitness.py             # Sharpe x (1-MaxDD) x WinRate
│   │   └── paper_trader.py        # mock execution, 0.2% spread
│   ├── data/
│   │   ├── __init__.py
│   │   ├── rss_ingestion.py       # CoinDesk, The Block, Decrypt
│   │   ├── price_feed.py          # CoinGecko REST
│   │   └── storage.py             # pgvector + Redis ops
│   ├── publish/
│   │   ├── __init__.py
│   │   ├── telegram.py            # channel posting
│   │   ├── deadman_switch.py      # 25-hour cadence guarantee
│   │   └── report_generator.py    # weekly performance
│   └── calibration/
│       ├── __init__.py
│       └── tracker.py             # confidence vs accuracy
├── tests/
│   ├── test_data.py
│   ├── test_signals.py
│   ├── test_tournament.py
│   └── test_calibration.py
├── sql/
│   ├── 001_signal_calibration.sql
│   ├── 002_tax_lots.sql
│   └── 003_strategy_state.sql
├── docker-compose.yml
├── Dockerfile
├── requirements.txt
└── .env.example
```

## Data Model

### signal_calibration
```sql
CREATE TABLE signal_calibration (
    signal_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    fired_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    asset VARCHAR(10) NOT NULL,
    confidence FLOAT NOT NULL CHECK (confidence BETWEEN 0 AND 1),
    direction VARCHAR(5) NOT NULL CHECK (direction IN ('LONG', 'SHORT')),
    reasoning TEXT,
    outcome VARCHAR(5) CHECK (outcome IN ('WIN', 'LOSS', NULL)),
    resolution_time TIMESTAMPTZ
);
```

### strategy_state
```sql
CREATE TABLE strategy_state (
    strategy_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    params JSONB NOT NULL,
    fitness FLOAT DEFAULT 0,
    sharpe_ratio FLOAT DEFAULT 0,
    max_drawdown FLOAT DEFAULT 0,
    win_rate FLOAT DEFAULT 0,
    total_signals INT DEFAULT 0,
    status VARCHAR(10) DEFAULT 'active' CHECK (status IN ('active', 'retired', 'champion'))
);
```

### tax_lots (FIFO)
```sql
CREATE TABLE tax_lots (
    lot_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset VARCHAR(10) NOT NULL,
    quantity DECIMAL(18,8) NOT NULL,
    cost_basis_eur DECIMAL(12,2) NOT NULL,
    acquired_at TIMESTAMPTZ NOT NULL,
    sold_at TIMESTAMPTZ,
    sale_price_eur DECIMAL(12,2),
    holding_period_days INT GENERATED ALWAYS AS (
        EXTRACT(DAY FROM COALESCE(sold_at, NOW()) - acquired_at)
    ) STORED
);
```

## Features

### Feature 1: Dual-Lane Signal Engine
**Behavior:** Fast lane (Phi-3-mini) runs every 15 min on RSS headlines. Deep lane (Mistral-7B) runs hourly with full narrative analysis + EMA 20/50 crossover.
**API Contract:** Internal -- signals stored in pgvector + Redis, consumed by tournament.
**Edge Cases:** Ollama timeout (>30s) -> skip signal, log gap. RSS down -> cached headlines up to 1 hour.
**Acceptance Criteria:**
- [ ] Fast lane produces signal within 2s of trigger
- [ ] Deep lane produces signal within 15s
- [ ] Signals stored in pgvector with embeddings
- [ ] Redis cache with correct TTL (5-min fast, 65-min deep)

### Feature 2: 20-Strategy Tournament
**Behavior:** 20 strategies via Latin Hypercube Sampling. Each paper trades independently. Fitness weekly. Walk-forward validation at week 4.
**Edge Cases:** Strategy with <8 signals after week 1 -> parameter perturbation, not retirement.
**Acceptance Criteria:**
- [ ] 20 distinct strategy configs generated
- [ ] Each strategy independently tracks P&L
- [ ] Fitness = Sharpe x (1 - MaxDrawdown) x WinRate
- [ ] 0.2% round-trip execution cost on all paper trades

### Feature 3: Calibration Tracker
**Behavior:** Every signal logged with confidence. Outcome resolved at holding period end. Weekly audit: confidence buckets vs accuracy.
**Acceptance Criteria:**
- [ ] Every signal creates a calibration row
- [ ] Outcomes populated at resolution time
- [ ] Weekly accuracy query runs correctly
- [ ] Threshold: conf >0.7 must be accurate >55%

### Feature 4: NullDrift Publisher
**Behavior:** Daily auto-post at 06:00 Berlin. Dead-man's switch at 25 hours.
**Acceptance Criteria:**
- [ ] Daily post template generates correctly
- [ ] Telegram message sends successfully
- [ ] Dead-man's switch fires on missed cadence
- [ ] No post contains directional advice (MiFID II)

## Failure Handling
| Failure | Detection | Response | Recovery |
|---------|-----------|----------|----------|
| Ollama timeout >30s | inference_timeout log | Skip signal | Retry next cycle |
| RSS unreachable | feed_down log | Use Redis cache | Cache valid 1 hour |
| pgvector down | db_unavailable log | Buffer in Redis | Flush on reconnect |
| Telegram API failure | publish_failed log | 3x backoff retry | Dead-man's switch |
| Fitness NaN | fitness_error log | Set to 0 | Flag for review |

## Environment Variables
| Variable | Purpose | Default |
|----------|---------|---------|
| OLLAMA_HOST | Ollama API endpoint | http://localhost:11434 |
| POSTGRES_URL | Database connection | -- |
| REDIS_URL | Redis connection | redis://localhost:6379 |
| TELEGRAM_BOT_TOKEN | Bot auth token | -- |
| TELEGRAM_CHANNEL_ID | Target channel | @NullDrift_ai |
| COINGECKO_API_URL | Price data | https://api.coingecko.com/api/v3 |

## Build Order

### Session 1: Data Layer
**Branch:** feat/data-layer
**Tag:** v0.1.0
**Depends on:** []
**Deliverables:**
- [ ] SQL migrations (signal_calibration, tax_lots, strategy_state)
- [ ] storage.py (pgvector + Redis operations)
- [ ] rss_ingestion.py (RSS feed parser)
- [ ] price_feed.py (CoinGecko client)
- [ ] Test infrastructure + tests for all data layer functions

**Verification Gates:**
```bash
python -m pytest tests/test_data.py -v
python -c "from src.data.storage import SignalStore; print('OK')"
```

**Quality Gates:**
```bash
# BLOCK: no hardcoded connection strings
grep -rn "postgresql://\|redis://" src/ --include="*.py" | grep -v "env\|config\|example" | wc -l  # expect: 0
```

---

### Session 2: Signal Engine
**Branch:** feat/signal-engine
**Tag:** v0.2.0
**Depends on:** [1]
**Deliverables:**
- [ ] fast_lane.py (Phi-3-mini 15-min sentiment)
- [ ] deep_lane.py (Mistral-7B hourly analysis)
- [ ] aggregator.py (composite signal)
- [ ] Tests for signal generation

**Verification Gates:**
```bash
python -m pytest tests/test_signals.py -v
python -c "from src.signals.fast_lane import FastLane; print('OK')"
```

**Quality Gates:**
```bash
# BLOCK: no hardcoded Ollama host
grep -rn "localhost:11434\|127.0.0.1:11434" src/ --include="*.py" | grep -v "env\|config\|example" | wc -l  # expect: 0
# WARN: inference timeout configured
grep -rn "timeout" src/signals/ --include="*.py" | wc -l  # expect: >0
```

**Scar Load:**
| ID | Category | Description | Severity |
|----|----------|-------------|----------|
| R1 | INTEGRATION | Ollama host must come from OLLAMA_HOST env var, never hardcoded | CRITICAL |
| R2 | SILENT-FAILURE | Ollama inference can hang silently -- always set timeout param | HIGH |

---

### Session 3: Tournament + Paper Trading
**Branch:** feat/tournament
**Tag:** v0.3.0
**Depends on:** [2]
**Deliverables:**
- [ ] tournament.py (20-strategy LHS generation + management)
- [ ] fitness.py (Sharpe x (1-MaxDD) x WinRate)
- [ ] paper_trader.py (mock execution with 0.2% spread)
- [ ] Tests for tournament logic

**Verification Gates:**
```bash
python -m pytest tests/test_tournament.py -v
python -c "from src.strategy.tournament import Tournament; t = Tournament(); assert len(t.strategies) == 20"
```

**Quality Gates:**
```bash
# WARN: test coverage
python -m pytest tests/ --cov=src --cov-report=term-missing 2>&1 | tail -5
```

---

### Session 4: Publisher + Calibration + Integration
**Branch:** feat/publisher
**Tag:** v0.4.0
**Depends on:** [3]
**Deliverables:**
- [ ] telegram.py (channel posting)
- [ ] deadman_switch.py (25-hour cadence guarantee)
- [ ] report_generator.py (weekly performance report)
- [ ] tracker.py (calibration logging + weekly audit)
- [ ] main.py (scheduler, ties everything together)
- [ ] Dockerfile + docker-compose.yml

**Verification Gates:**
```bash
python -m pytest tests/ -v
docker compose build
python -c "from src.main import app; print('OK')"
```

**Quality Gates:**
```bash
# BLOCK: no directional advice in templates
grep -rn "buy\|sell\|enter position\|go long\|go short" src/publish/ --include="*.py" -i | grep -v "paper_\|test_\|#" | wc -l  # expect: 0
# BLOCK: dead-man's switch independent of main process
grep -rn "deadman\|health.check" docker-compose.yml | wc -l  # expect: >0
```

**Scar Load:**
| ID | Category | Description | Severity |
|----|----------|-------------|----------|
| R3 | CORRECTNESS | Posts must never contain directional advice -- MiFID II | CRITICAL |
| R4 | SILENT-FAILURE | Dead-man's switch must fire even if main crashes -- needs separate health check | HIGH |

## Addendum
[Reserved for corrections during execution.]
