CREATE TABLE IF NOT EXISTS metadata_index (
    id SERIAL PRIMARY KEY,
    traffic_light_id VARCHAR(255),
    timestamp BIGINT,
    type VARCHAR(50)
);