var db = db.getSiblingDB("admin");
db.createUser(
    {
        user: "clusterAdmin",
        pwd: "clusterAdmin",
        roles:
            [
                { role: "clusterAdmin", db: "admin" }
            ]
    })
db.createUser(
    {
        user: "dbAdminAnyDatabase",
        pwd: "dbAdminAnyDatabase",
        roles:
            [
                { role: "dbAdminAnyDatabase", db: "admin" }
            ]
    })
db.createUser(
    {
        user: "userAdminAnyDatabase",
        pwd: "userAdminAnyDatabase",
        roles:
            [
                { role: "userAdminAnyDatabase", db: "admin" }
            ]
    })
