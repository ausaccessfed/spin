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
   "organisations":[
      {
         "id":1,
         "shared_token":"W4ohH-6FCupmiBdwRv_w18AToQ"
         "mail":"russell.ianniello@aaf.edu.au",
         "name":"Russell Ianniello"
      },
      {
         "id":2,
         "shared_token":"6FCupmW4ohH-iBdwRv_w18AToQ"
         "mail":"joe.blogs@aaf.edu.au",
         "name":"Joe Blogs"
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
{ "organisation":  { "name": "Org 1", "external_id": "ExtID1" } }
```

### Response

```
Status: 200 OK
```

## Update Organisation

```
PATCH /api/organisations/:id
Content-Type: application/json
{ "organisation":  { "name": "Org 1 - UPDATE", "external_id": "ExtID1 - UPDATE" } }
```

### Response

```
Status: 200 OK
```
