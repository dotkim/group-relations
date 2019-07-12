# group-relations

This a currently mostly focused on the SQL part.
All data was put into a mongoDB and later merged to MSSQL for relational purposes.
Simply said, the relational model is easier than creating relations in the application...

The database is not "done", but should be fully able to use.

The point of this:

- Collect data from AD, groups and members of those groups. (Needs to be reworked, as the "users" table also get filled with groups)
- Collect data from applications that use AD groups etc for permissions.
- Relate ad groups and applications, folder, etc.
- Find uneeded groups and get a better overview of the AD and application environment.
