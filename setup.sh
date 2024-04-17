#!/bin/bash


echo -e "                                                       ";
echo -e "   ______                                              ";
echo -e "  / ____/___  ____  ____ ___  _____  _________  _____  ";
echo -e " / /   / __ \/ __ \/ __  / / / / _ \/ ___/ __ \/ ___/  ";
echo -e "/ /___/ /_/ / / / / /_/ / /_/ /  __/ /  / /_/ / /      ";
echo -e "\____/\____/_/ /_/\__  /\__ _/\___/_/   \____/_/       ";
echo -e "                    /_/                                ";
echo -e "                                                       ";

echo -e "\033[38;5;245mTwitter : https://twitter.com/cqrlabs_tech\033[0m"
echo -e "\033[38;5;245mGithub  : https://github.com/DasRasyo\033[0m"
sleep 7
prompt() {
  read -p "$1: " val
  echo $val
}
echo -e "\033[38;5;205m⚠️Starting with Packages update and Dependencies Inslall⚠️\033[0m"
sleep 5

sudo apt update && apt upgrade -y && sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential \
git make ncdu -y 

sleep 5

echo -e "\033[38;5;205m⚠️Installing GO⚠️\033[0m"

sleep 10

cd $HOME
curl -Ls https://go.dev/dl/go1.20.1.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
touch $HOME/.bash_profile
source $HOME/.bash_profile
PATH_INCLUDES_GO=$(grep "$HOME/go/bin" $HOME/.bash_profile)
if [ -z "$PATH_INCLUDES_GO" ]; then
  echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile
  echo "export GOPATH=$HOME/go" >> $HOME/.bash_profile
fi
eval $(echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/golang.sh)
eval $(echo 'export PATH=$PATH:$HOME/go/bin' | tee -a $HOME/.profile)
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile
source $HOME/.bash_profile

sleep 5

source $HOME/.bash_profile

echo -e "\033[38;5;205mPackages updated, Go and Dependencies Inslalled. You can check your go version with = go version\033[0m"

sleep 7

echo -e "\033[35mSetting Up 0g\033[0m"

sleep 5

cd $HOME 
rm -rf 0g-evmos 
git clone https://github.com/0glabs/0g-evmos.git
cd 0g-evmos/ 
git checkout v1.0.0-testnet
make install

sleep 8
source $HOME/.bash_profile
sleep 3

echo -e "\033[35mInitializing the 0g\033[0m"

sleep 5

node_name=$(prompt "Enter your node name")
evmosd init $node_name --chain-id zgtendermint_9000-1

sleep 8

wget https://github.com/0glabs/0g-evmos/releases/download/v1.0.0-testnet/genesis.json -O $HOME/.evmosd/config/genesis.json

PEERS="2deae598a1a29bfb9bd035709e8946757e1930dc@194.163.168.52:26656,d813235cc2326983e0ea071ffa8acba341df0adb@89.117.56.219:16456,2fa2b10211cc68b34dfc86e213a201bb62fb6d19@209.145.55.212:26656,755f82bd214ec2370654b736598d2524a6bfb8ea@75.119.147.54:16656,ac1d78038dfa515ec5e44db02831ceb2d1d1d57e@75.119.136.242:26656,e42499ec89c76482a5a4183f1f604a5f520c3aeb@62.171.176.231:26656,4dd10ff83ea62fb0ed96052436a7d4bb1a3e19eb@84.247.189.178:26656,26a46d75a84a3a64145fcf2e434e2547384e943b@37.57.147.116:26656,4eb8c2962b311b95ec21eb872b9c19ef18a803c3@65.108.211.117:16456,df7631e171648847399cd836d3db761a15abe38a@37.27.87.154:26656,51fa59f671c4cba929cb33a693252f2416d3ee01@37.27.0.228:26656,43ef7d078759b62dca2871a8b9c6333ab0136df8@5.189.145.105:26656,d4cfa06317704bea6062563a828e1006d727ee9c@185.192.96.52:26656,28cd041ab9f8249cb55ddd95a38be855bcff7fdf@84.247.138.89:26666,4e7a2f96750d2252fda39a5eafa6b81a00602762@173.212.249.35:26656" && \
SEEDS="8c01665f88896bca44e8902a30e4278bed08033f@54.241.167.190:26656,b288e8b37f4b0dbd9a03e8ce926cd9c801aacf27@54.176.175.48:26656,8e20e8e88d504e67c7a3a58c2ea31d965aa2a890@54.193.250.204:26656,e50ac888b35175bfd4f999697bdeb5b7b52bfc06@54.215.187.94:26656" && \
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.evmosd/config/config.toml

sleep 5

echo -e "\033[35mSetting pruning\033[0m"

sed -i.bak -e "s/^pruning *=.*/pruning = \"custom\"/" $HOME/.evmosd/config/app.toml
sed -i.bak -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" $HOME/.evmosd/config/app.toml
sed -i.bak -e "s/^pruning-interval *=.*/pruning-interval = \"10\"/" $HOME/.evmosd/config/app.toml

evmosd tendermint unsafe-reset-all --home $HOME/.evmosd --keep-addr-book

sleep 5

echo -e "\033[35mStarting 0g Service\033[0m"

sleep 3

sudo tee /etc/systemd/system/ogd.service > /dev/null <<EOF
[Unit]
Description=OG Node
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=$(which evmosd) start --home $HOME/.evmosd
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sleep 3

sudo systemctl enable ogd
sudo systemctl restart ogd

sleep 3


echo -e "\033[35mDownloading Snapshot for Quick Sync. Please wait\033[0m"
sleep 20
sudo apt install snapd -y
sudo snap install lz4

wget https://rpc-zero-gravity-testnet.trusted-point.com/latest_snapshot.tar.lz4
sudo systemctl stop ogd
cp $HOME/.evmosd/data/priv_validator_state.json $HOME/.evmosd/priv_validator_state.json.backup
evmosd tendermint unsafe-reset-all --home $HOME/.evmosd --keep-addr-book
lz4 -d -c ./latest_snapshot.tar.lz4 | tar -xf - -C $HOME/.evmosd
mv $HOME/.evmosd/priv_validator_state.json.backup $HOME/.evmosd/data/priv_validator_state.json
sudo systemctl restart ogd
sleep 5

echo -e "\033[35mSnapshot Downloaded. Service Restarted.\033[0m"

sleep 3

echo -e "\033[35mCongrats!! Your node started!\033[0m"
sleep 3
echo -e "\033[35mSome Useful Command That You May Need For 0g Service. Copy and Save!\033[0m"
sleep 3
echo -e "\033[35mCheck Your Logs:       sudo journalctl -u ogd -f --no-hostname -o cat\033[0m"
sleep 3
echo -e "\033[35mStop the Service:      sudo systemctl stop ogd\033[0m"
sleep 3
echo -e "\033[35mStart the Service:     sudo systemctl start ogd\033[0m"
sleep 3
echo -e "\033[35mRestart the Service:   sudo systemctl restart ogd\033[0m"
sleep 10

echo -e "\033[31m⚠️⚠️⚠️Lets create a wallet! Please do not forget to save your mnemonics!!!. If you dont save you can not access your wallet. After creating wallet, you will have 100 second to save your mnemonics. After that script will continued!⚠️⚠️⚠️\033[0m"
sleep 3
echo -e "\033[31m⚠️ Before creating your validator do not forget to top up your wallet with some testnet coin! ⚠️\033[0m"
sleep 3
echo -e "\033[31m⚠️⚠️⚠️ SAVE THE MNEMONICS⚠️⚠️⚠️\033[0m"
sleep 17

wallet_name=$(prompt "Enter your wallet name")
evmosd keys add $wallet_name

sleep 100

echo -e "\033[38;5;205mWith this script we automaticly check if your node fully synced. After synced you can go on with creating your validator. The script will check sync status every 60 seconds and will print the status.\033[0m"

while true
do

    sync_status=$(curl -s localhost:26657/status | jq '.result | .sync_info | .catching_up')
        if [ "$sync_status" = "false" ]; then
        echo "Your node is synced with the network."
            sleep 5
            echo "Your node is now synced with the network. Proceed with validator creation."
            sleep 5
            echo "Stop the script with ctrl C and edit the following command with your information to create your validator!"
            sleep 10
            echo -e "\033[38;5;205mevmosd tx staking create-validator --amount=10000000000000000aevmos --pubkey=$(evmosd tendermint show-validator) --moniker=MONIKER --chain-id=zgtendermint_9000-1 --commission-rate=0.05 --commission-max-rate=0.10 --commission-max-change-rate=0.01 --min-self-delegation=1 --from=WALLET_NAME --identity="" --website="" --details="" --gas=500000 --gas-prices=99999aevmos -y\033[0m"
		sleep 20

        else
       echo "Your node is not synced with the network. Waiting for sync to complete..."
           sleep 60
        fi
done
