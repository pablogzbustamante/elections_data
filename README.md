# US Elections Data Platform
#### Full-stack web application for exploring 2024 U.S. Presidential election results enriched with county-level demographic data.

The project includes:
<ul>  
  <li>PostgreSQL relational data warehouse (raw / dim / fact schemas)</li>
  <li>SQL transformation pipeline</li>
  <li>Node.js backend API</li>
  <li>Node.js backend API</li>
  <li>Dockerized database environment</li>
  <li>Fully reproducible setup from scratch</li>
</ul>

### Project Structure
```text
elections_data/
├── backend/              # Node.js API
├── frontend/             # React (Vite) application
├── db/
│   ├── 01_schema.sql     # Database schema (DDL only)
│   ├── 02_load.sql       # Raw CSV load
│   └── 03_transform.sql  # Dim/Fact transformations
│
├── datasets/             # Source CSV files
├── docker-compose.yml
├── .gitignore
└── README.md
```

## Requirements
<ol>
  <li>Docker Desktop</li>
  <li>PostgreeSQL client tools (psql)</li>
  <li>Node.js (v18+ recommended)</li>
  <li>Git</li>
</ol>

## 1. Database Setup (Docker)
Start PostgreSQL

<code>docker compose up -d</code>

## 2. Initialize Database (Schema + Data)
All commands must be executed from the project root directory.
### 2.1 Create Database
<code>createdb -U postgres elections_data</code>

(If createdb is not in PATH, use the full path to the PostgreSQL bin directory.)


### 2.2 Create Database
<code>psql -U postgres -d elections_data -f db/01_schema.sql</code>

This creates:
<ul>  
  <li>psql -U postgres -d elections_data -f db/01_schema.sql</li>
  <li>Tables</li>
  <li>Constraints</li>
  <li>Indexes</li>
  <li>Views</li>
</ul>

### 2.3 Load Raw Data
<code>psql -U postgres -d elections_data -f db/02_load.sql</code>
This loads:
<ul>
  <li>datasets/DemographicsData.csv</li>
  <li>datasets/elections_data.csv</li>
</ul>

### 2.4 Transform and Populate Dim/Fact
<code>psql -U postgres -d elections_data -f db/03_transform.sqll</code>
This script:
<ul>
  <li>Populates dimension tables</li>
  <li>Populates fact tables</li>
  <li>Casts and cleans raw data</li>
  <li>Enforces referential integrity</li>
</ul>

## 3. Verification
Run:

<code>SELECT COUNT(*) FROM raw.elections_data;</code>

<code>SELECT COUNT(*) FROM dim.state;</code>

<code>SELECT COUNT(*) FROM dim.county;</code>

<code>SELECT COUNT(*) FROM fact.county_election_summary;</code>

<code>SELECT COUNT(*) FROM fact.v_state_summary_2024;</code>


All counts should be greater than zero.

## 4. Backend Setup

<code>cd backend</code>

<code>npm install</code>

Create a .env file based on .env.example.

Example:

<code>DB_HOST = localhost</code>

<code>DB_PORT=5432</code>

<code>DB_USER=postgres</code>

<code>DB_PASSWORD=your_password</code>

<code>DB_NAME=elections_data</code>

Start backend:

<code>npm run dev</code>


## 5. Frontend Setup
<code>cd frontend</code>

<code>npm install</code>

Create a .env file based on .env.example.

Example:

<code>VITE_API_URL=http://localhost:5000</code>

Start frontend:

<code>npm run dev</code>

App runs at:

<code>http://localhost:5173</code>

## Reproducibility Summary
Reproducibility Summary

<ol>
  <li>Clone repository</li>
  <li>Run <code>docker compose up -d</code></li>
  <li>Execute:
    <ul>
      <li><code>01_schema.sql</code></li>
      <li><code>02_load.sql</code></li>
      <li><code>03_transform.sql</code></li>
    </ul>
  </li>
  <li>Install backend dependencies</li>
  <li>Install frontend dependencies</li>
</ol>

No manual data entry required.

## Security Notes
The repository excludes:
<ul>
  <li><code>node_modules/</code></li>
  <li><code>.env/</code> files</li>
  <li>build artifacts</li>
  <li>logs</li>
 </ul>
Use <code>.env.example</code> as a template.  
