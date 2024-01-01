NODENAME=xxx
AVAIL_PORT=30333
echo "export NODENAME=$NODENAME" >> $HOME/.bashrc
echo "export AVAIL_PORT=${AVAIL_PORT}" >> $HOME/.bashrc
source $HOME/.bashrc

apt update &&  apt upgrade -y
apt install  curl gcc  wget clang pkg-config protobuf-compiler libssl-dev jq build-essential protobuf-compiler bsdmainutils git make  chrony liblz4-tool -y
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env
rustup default stable
rustup update
rustup update nightly
rustup target add wasm32-unknown-unknown --toolchain nightly

git clone https://github.com/availproject/avail.git
cd avail
mkdir -p data
git checkout v1.8.0.2
cargo build --release -p data-avail
cp $HOME/avail/target/release/data-avail /usr/bin


tee /etc/systemd/system/availd.service > /dev/null <<EOF
[Unit]
Description=Avail Validator
After=network-online.target

[Service]
User=$USER
ExecStart=/usr/bin/data-avail -d /root/ava_data --chain goldberg --validator --name $NODENAME  --out-peers 100
Restart=always
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF


systemctl daemon-reload && systemctl enable availd && systemctl restart availd &&  journalctl -fu availd 



curl -H "Content-Type: application/json" -d '{"id":1, "jsonrpc":"2.0", "method": "author_rotateKeys", "params":[]}' http://localhost:9944
