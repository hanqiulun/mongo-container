gluster volume create mongo1-1 stripe 2 transport tcp node02:/opt/mongo1-1 node03:/opt/mongo1-1 node04:/opt/mongo1-1 node05:/opt/mongo1-1 force
gluster volume create mongo1-2 stripe 2 transport tcp node02:/opt/mongo1-2 node03:/opt/mongo1-2 node04:/opt/mongo1-2 node05:/opt/mongo1-2 force
gluster volume create mongo1-3 stripe 2 transport tcp node02:/opt/mongo1-3 node03:/opt/mongo1-3 node04:/opt/mongo1-3 node05:/opt/mongo1-3 force
gluster volume create mongo2-1 stripe 2 transport tcp node02:/opt/mongo2-1 node03:/opt/mongo2-1 node04:/opt/mongo2-1 node05:/opt/mongo2-1 force
gluster volume create mongo2-2 stripe 2 transport tcp node02:/opt/mongo2-2 node03:/opt/mongo2-2 node04:/opt/mongo2-2 node05:/opt/mongo2-2 force
gluster volume create mongo2-3 stripe 2 transport tcp node02:/opt/mongo2-3 node03:/opt/mongo2-3 node04:/opt/mongo2-3 node05:/opt/mongo2-3 force

gluster volume start mongo1-2

gluster volume quota mongo1-2 enable


apiVersion: v1
kind: Endpoints
metadata:
  name: mongo2-3
subsets:
- addresses:
  - ip: 10.60.81.204
  ports:
  - port: 1995
- addresses:
  - ip: 10.60.81.205
  ports:
  - port: 1995
- addresses:
  - ip: 10.60.81.206
  ports:
  - port: 1995
- addresses:
  - ip: 10.60.81.207
  ports:
  - port: 1995
- addresses:
  - ip: 10.60.81.208
  ports:
  - port: 1995