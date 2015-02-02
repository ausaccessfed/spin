# Organisations

## List Organisations

List all Organisations

```
GET /api/organisations
```

### Response

```
Status: 200 OK
```

```json
{
    "organisations": [
        {
            "id": 1,
            "name": "Organisation 1",
            "external_id": "ORG1"
        },
        {
            "id": 2,
            "name": "Organisation 2",
            "external_id": "ORG2"
        }
    ]
}
```

## Delete Organisation

Delete Organisation by id

```
DELETE /api/organisations/:id
```
### Response

```
Status: 200 OK
Response: Organisation <id> deleted
```

## Create Organisation

```
POST /api/organisations
Content-Type: application/json
```
Request Body:
```json
{ "organisation":  { "name": "Org 1", "external_id": "ExtID1" } }
```

### Response

```
Status: 200 OK
Response: Organisation <id> created
```

## Update Organisation

```
PATCH /api/organisations/:id
Content-Type: application/json
```
Request Body:
```json
{ "organisation":  { "name": "Org 1 - UPDATE", "external_id": "ExtID1 - UPDATE" } }
```

### Response

```
Status: 200 OK
Response: Organisation <id> updated
```
