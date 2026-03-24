# Trip App

A Rails **API-only** service that exposes **REST JSON** endpoints for managing **trips** (destinations with descriptions, images, and ratings). It uses **PostgreSQL**, **Kaminari** for pagination, and **Active Model Serializers** for response shaping on single-trip actions.

## Requirements

- **Ruby** 3.2.7 (see `.ruby-version`)
- **PostgreSQL** 9.3+
- **Bundler**

## Setup

```bash
bundle install
```

Configure the database in `config/database.yml` (defaults use local PostgreSQL databases `trip_app_development` and `trip_app_test`).

Create and migrate the database:

```bash
bin/rails db:create
bin/rails db:migrate
```

Optional sample data from `db/seeds/trips.json`:

```bash
bin/rails db:seed
```

## Run the application

```bash
bin/rails server
```

The API is served at `http://localhost:3000` by default.

## Health check

| Method | Path  | Description        |
| ------ | ----- | ------------------ |
| GET    | `/up` | Rails health check |

## API (`/api/v1`)

All JSON endpoints expect `Content-Type: application/json` where a body is sent.

### List trips

`GET /api/v1/trips`

Returns a paginated list. Each item includes `id`, `name`, `image_url`, `short_description`, and `rating` (not `long_description`).

**Query parameters**

| Parameter    | Description                                                                 |
| ------------ | --------------------------------------------------------------------------- |
| `page`       | Page number (Kaminari).                                                     |
| `per_page`   | Items per page (default **10**).                                            |
| `search`     | Case-insensitive substring match on `name` (PostgreSQL `ILIKE`).            |
| `min_rating` | Only trips with `rating` greater than or equal to this value.               |
| `sort`       | `rating_asc`, `rating_desc`, or omit / other values for **name ascending**. |

**Response shape**

```json
{
  "data": [
    {
      "id": 1,
      "name": "Example",
      "image_url": "https://example.com/photo.jpg",
      "short_description": "…",
      "rating": 5
    }
  ],
  "meta": {
    "current_page": 1,
    "total_pages": 1,
    "total_count": 10,
    "per_page": 10
  }
}
```

### Show trip

`GET /api/v1/trips/:id`

Returns one trip with all attributes serialized (including `long_description`).

### Create trip

`POST /api/v1/trips`

**Request body** (nested `trip` object):

```json
{
  "trip": {
    "name": "Example Park",
    "image_url": "https://example.com/image.jpg",
    "short_description": "Short text",
    "long_description": "Longer text",
    "rating": 4
  }
}
```

- **Success:** `201 Created` with the created trip JSON.
- **Validation errors:** `422 Unprocessable Content` with `{ "errors": { "field": ["message"] } }`.

**Constraints (application / DB):** `name` is unique; `rating` must be **1–5**; `image_url` must look like a valid URI.

## Tests

```bash
bin/rails db:test:prepare
bundle exec rspec
```

Request specs live under `spec/requests/api/v1/`.
