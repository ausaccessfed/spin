# Subjects

## Get Subject

The following `Subject` attributes will be returned:

1. id
2. name
3. mail
4. shared_token
5. complete
5. created_at
6. updated_at

In addition if the `Subject` is considered incomplete (there is an outstanding invitation pending) the following is be provided:

1. invitation_url
2. invitation_created_at

### Request

```
GET /api/subjects/1
```

### Response

```
Status: 200 OK
```

```json
{
   "subject": {
       "id":1,
       "name":Russell Ianniello,
       "mail":"russell.ianniello@aaf.edu.au",
       "shared_token":"W4ohH-6FCupmiBdwRv_w18AToQ"
       "complete":"true"
       "created_at":"2015-03-04T23:52:58Z"
       "updated_at":"2015-03-03T00:01:23Z"
    },
    "invitations":[
        {
           "invitation_url":"https://example.com/invitations/4GSFFDJH22341",
           "invitation_created_at":"2015-03-04T23:52:58Z"
        }
    ]
}
```

## List Subjects

List all Subjects

```
GET /api/subjects
```

### Response

```
Status: 200 OK
```

```json
{
   "subjects":[
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

## Delete Subject

Delete Subject by id

```
DELETE /api/subjects/:id
```
### Response

```
Status: 200 OK
```

## Create Subject

To create a new `Subject` the following components can be specified in JSON as part of the request:

| Name | Type | Description | Optional | Value when unspecified |
|---|---|---|---|---|
| name | string | The display name for the Subject that should be created | No | |
| mail | string | The email address for the Subject that should be created | No | |
| shared_token | string | auEduPersonSharedToken for the Subject that should be created | Yes | |
| send_invitation | boolean | Indicates if invitation should be generated and delivered. | Yes | **true** |

The API functions as follows:

1. If `send_invitation` is set by the caller to `false` internal email is not generated or sent by SPIN. In this case the remote caller will be solely responsible for requesting that the Subject visits the SPIN invitation completion URL by whatever mechanism they choose.
2. When only `name` and `mail` are specified:
	1. If there is no matching `Subject` record based on mail an inactive `Subject` will be created. The `Subject` will become active after the invitation URL has been followed and the Subject completes a full login to SPIN.

		##### Successful API Responses
		Response will be a 201 including appropriate Location header referencing `Subject` GET url. JSON response body will also include the created Subject's internal ID for assisting with subsequent API requests.

		In addition when:

		2. `send_invitation`is **true** - An email will be generated and distributed to address identified in `mail`.
		3. `send_invitation`is **false** - The JSON response also indicates the SPIN URL as `invitation_url` which the remote system must request the Subject accesses in order to complete the invitation process.

		##### Erroneous API Responses
		Per standard AAF API response codes as already documented.

	1. If there is a matching `Subject` record a `400 Bad Request` with detailed error message is provided.

2. When `name`, `mail` and `shared_token` are specified:
	1. If there is no matching `Subject` record based on mail and shared_token an active `Subject` will be created. There is *no requirement to further communicate with the Subject in this scenario*. Advising the Subject of their new account is the responsibility of the caller.

		##### Successful API Responses
		Response will be a 201 including appropriate Location header referencing `Subject` GET url. JSON response body will also include the created Subject's internal ID for assisting with subsequent API requests.

		##### Erroneous API Responses
		Per standard AAF API response codes as already documented.

	1. If there is a matching `Subject` record a `400 Bad Request` with detailed error message is provided.


### Request (without invitation)
```
POST /api/subjects
Content-Type: application/json
```

```json
{
    "name":"Joe Bloggs",
    "mail":"test@example.com",
    "send_invitation":"false"
}
```

### Response

```
Status: 201 OK
Location: https://spin-instance.com.au/api/subjects/1
```

```json
{
    "subject_id": "1",
    "invitation_url": "https://spin-instance.com.au/api/invitations/43j1FJAJFBZ"
}
```

### Request (with invitation)
```
POST /api/subjects
Content-Type: application/json
```

```json
{
    "name": "Joe Bloggs",
    "mail": "test@example.com"
}
```

### Response

```
Status: 201 OK
Location: https://spin-instance.com.au/api/subjects/1
```

```json
{
    "subject_id":"1"
}
```
