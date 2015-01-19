# SPIN

SPIN provides a means for researchers to authenticate via the AAF to access to a project account in Amazon Web Services (AWS)

## Testing

Here is some rails/console scripts to test with ...

```ruby
o = Organisation.create!(name: "Test Org", external_id: "ID1" )
p = Project.create!(name:"Test Proj 1", aws_account: "AWS_ACC1", state: "A", organisation_id: o.id)
s = Subject.create!(mail: "russell.ianniello@aaf.edu.au", name: "Russell Ianniello", targeted_id: "https://rapid.test.aaf.edu.au!http://localhost:8080!sVU8U1bEIkdK+FTWuGQEv9aEJ+o=", shared_token: nil)
pr = ProjectRole.create!(name:"ALL for Test Proj 1", aws_identifier: "TP1", project_id: p.id)
spr = SubjectProjectRole.create!(subject_id: s.id, project_role_id: pr.id)

r = Role.create!(name: 'Admin')
pm = Permission.create!(role_id:r.id, value:'*')
sr = SubjectRole.create!(subject_id:Subject.last.id, role_id:r.id)
```

## Deployment configuration

The SPIN logo is configured by overwriting the files
* app/assets/images/logo.png
* app/assets/images/favicon.png

Configure the user consent and support text
* config/support.md
* config/consent.md
