# A tunnel deployment script

1. Run in server side (VPS or some host has public ip)
```
curl -s 'https://ghproxy.com/https://raw.githubusercontent.com/marsbasex/tunnel/master/deploy.sh' | sudo bash -s -- --server
```

2. Run in client side like NUC box, which $server_ip is public ip of your server above
```
curl -s 'https://ghproxy.com/https://raw.githubusercontent.com/marsbasex/tunnel/master/deploy.sh' | sudo bash -s -- --client $server_ip

```

Also you can check if the server is accessible. To run script from client:
```
curl -s 'https://ghproxy.com/https://raw.githubusercontent.com/marsbasex/tunnel/master/deploy.sh' | sudo bash -s -- --check $server_ip

```

You can access manager board from `http://$server_ip:18080` after deployment.
