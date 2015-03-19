---
---

## List

List all Projects

```
GET /api/organisations/:id/projects/
```

### Response

```
Status: 200 OK
```

```json
{
   "projects":[
      {
         "id":1,
         "provider_arn":"arn:aws:iam::1:saml-provider/12321"
         "active":"true",
         "name":"Project X"
      },
      {
         "id":2,
         "provider_arn":"arn:aws:iam::1:saml-provider/123115"
         "active":"true",
         "name":"Project Z"
      }
   ]
}
```

---

## Delete

Delete Project by id

```
DELETE /api/organisations/:id/projects/:id
```
### Response

```
Status: 200 OK
```

---

## Create

```
POST /api/organisations/:id/projects/
Content-Type: application/json
```
Request Body:
```json
{
   "project":{
      "name":"Proj 1",
      "provider_arn":"arn:aws:iam::1:saml-provider/5112",
      "active":"true"
   }
}
```

### Response

```
Status: 201 OK
```

---

## Update

```
PATCH /api/organisations/:id/projects/:id
Content-Type: application/json
```
Request Body:
```json
{
   "project":{
      "name":"Proj 2",
      "provider_arn":"arn:aws:iam::1:saml-provider/4",
      "active":"false"
   }
}
```

### Response

```
Status: 200 OK
```
