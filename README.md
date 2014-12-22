# SPIN

SPIN provides a means for researchers to authenticate via the AAF to access to a project account in Amazon Web Services (AWS)

## Testing

Here is some rails/console scripts to test with ...

```ruby
o = Organisation.create!(name: "Test Org", external_id: "ID1" )
p = Project.create!(name:"Test Proj 1", aws_account: "AWS_ACC1", state: "A", organisation_id: 1)
s = Subject.create!(mail: "russell.ianniello@aaf.edu.au", name: "Russell Ianniello", targeted_id: "https://rapid.test.aaf.edu.au!http://localhost:8080!sVU8U1bEIkdK+FTWuGQEv9aEJ+o=", shared_token: nil)
r = ProjectRole.create!(name:"ALL for Test Proj 1", aws_identifier: "TP1", project_id: 1)
spr = SubjectProjectRole.create!(subject_id: 1, project_role_id: 1)
```
