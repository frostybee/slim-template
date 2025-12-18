# Database Initialization

Place your `.sql` files in this directory. They will be automatically imported when the database container starts for the first time.

## Notes

- Files are executed in alphabetical order (e.g., `01-schema.sql`, `02-data.sql`)
- Scripts only run on first container creation
- To re-import, remove the volume: `docker-compose down -v` then `docker-compose up`
