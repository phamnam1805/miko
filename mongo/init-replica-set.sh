kubectl exec -it mongodb-stateful-set-0 -- mongosh -u miko -p miko --eval "rs.initiate({
  _id: 'rs0',
  members: [
    { _id: 0, host: 'mongodb-stateful-set-0.mongodb-headless-service:27017' },
    { _id: 1, host: 'mongodb-stateful-set-1.mongodb-headless-service:27017' }
  ]
});"



