# export ADDRESS=185.212.252.108
export ADDRESS=185.212.252.251

export XSRF="2|c7c19e2d|888a528881df8786961287fb44f68226|1597595822"

# curl -i -X POST \
#      --cookie "_xsrf=$XSRF" \
#      -F "_xsrf=$XSRF" \
#      -F "username=freeuni" \
#      -F "password=freeuni" \
#      "$ADDRESS/Freeuni/login"

curl -i -X GET \
     --cookie "_xsrf=$XSRF" \
     --cookie "Freeuni_login=2|1:0|10:1597595838|13:Freeuni_login|56:WyJmcmVldW5pIiwgImZyZWV1bmkiLCAxNTk3NTk1ODM4LjQwNDA0NV0=|808b376ddb203f1b765eaf658ff36767710135baa01d96f97e2e016f0f5588b7" \
     "$ADDRESS/Freeuni/tasks/vector/attachments/vector.zip"
