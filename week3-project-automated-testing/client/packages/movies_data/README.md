# movies_data

Ownership and public contracts follow client/specs/03_architecture_and_monorepo.md.

Fixture catalog is deliberately synthetic and uses locally rendered studio artwork; it never contacts TMDB or an image CDN. Favorites use real Drift transactions and separate live/fixture databases. Schema history is in drift_schemas/drift_schema_v1.json. Runtime/generator use matched Drift 2.34.0 after actual schema-export verification.
