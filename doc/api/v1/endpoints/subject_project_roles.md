---
---

### Subject / Project Roles (```/api/organisations/:id/projects/:id/roles/:id/members```)

---

## Associate

```
POST /api/organisations/:id/projects/:id/roles/:id/members
Content-Type: application/json
```
Request Body:

```json
{
   "subject_project_roles":{
      "subject_id":"<id>"
   }
}
```

### Response

```
Status: 201 OK
```

---

## Disassociate

```
DELETE /api/organisations/:id/projects/:id/roles/:id/members/:subject_id
```
### Response

```
Status: 200 OK
```
