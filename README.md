# jitsi_all_in_one
Jitsi all in one

## Alla moduler runt Jitsi
```
docker compose up -d
```

## Jitsi
```
mkdir jitsi
cd jitsi
```
Ladda ner 
```
wget $(curl -s https://api.github.com/repos/jitsi/docker-jitsi-meet/releases/latest | grep 'zip' | cut -d\" -f4)
mv xxxx xxxx.zip
unzip xxxx.zip
cp env.example .env
```
Ändra i .env
```
vim .env
```

```
docker compose up -d
```
