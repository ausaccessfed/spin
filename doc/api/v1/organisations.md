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
            "unique_identifier": "UniqueIdentifier1"
        },
        {
            "id": 2,
            "name": "Organisation 2",
            "unique_identifier": "UniqueIdentifier2"
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
```

## Create Organisation

```
POST /api/organisations
Content-Type: application/json
```
Request Body:
```json
{
   "organisation":{
      "name":"Org 1",
      "unique_identifier":"UniqueIdentifier1"
   }
}
```

### Response

```
Status: 201 OK
```

## Update Organisation

```
PATCH /api/organisations/:id
Content-Type: application/json
```
Request Body:
```json
{
   "organisation":{
      "name":"Org 1 - UPDATE",
      "unique_identifier":"UniqueIdentifier1 - UPDATE"
   }
}
```

### Response

```
Status: 200 OK
```
