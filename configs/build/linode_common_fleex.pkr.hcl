
locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

variable "HOME" {                                                                                                                            
  type = string
  default = "${env("HOME")}" 
}

variable "IMAGE" {                                                                                                                            
  type = string
  default = "linode/ubuntu20.04" 
}

variable "SIZE" {                                                                                                                            
  type = string
  default = "g6-nanode-1" 
}

variable "REGION" {                                                                                                                            
  type = string
  default = "eu-central" 
}

variable "TOKEN" {                                                                                                                            
  type = string
  default = "" 
}


source "linode" "fleex" {
  image             = "${var.IMAGE}"
  image_description = "Fleex packer linode image"
  image_label       = "linode-fleex-${local.timestamp}"
  instance_label    = "common-linode-fleex-${local.timestamp}"
  instance_type     = "${var.SIZE}"
  linode_token      = "${var.TOKEN}"
  region            = "${var.REGION}"
  ssh_username      = "root"
}

build {
  sources = ["source.linode.fleex"]

  provisioner "file" {
    source = "${var.HOME}/fleex/configs"
    destination = "/tmp/configs"
  }

  provisioner "shell" {
    inline = [
        "fallocate -l 2G /swap && chmod 600 /swap && mkswap /swap && swapon /swap",
        "echo '/swap none swap sw 0 0' | sudo tee -a /etc/fstab",
        "add-apt-repository -y ppa:longsleep/golang-backports",
        "echo Apt-get update",
        "apt-get update -qq",
        "echo Apt-get upgrade",
        "DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confnew upgrade -qq",
        "echo Apt-get install all ma packages",
        "DEBIAN_FRONTEND=noninteractive sudo apt -qqy install apt-transport-https fail2ban ca-certificates unzip debian-keyring curl zlib1g-dev libpcap-dev ruby-dev nmap dirmngr gnupg-agent gnupg2 libpq-dev software-properties-common fonts-liberation libappindicator3-1 libcairo2 libgbm1 libgdk-pixbuf2.0-0 libgtk-3-0 libxss1 xdg-utils jq ufw net-tools golang-go masscan zsh make",
        "ufw allow 22",
        "ufw allow 2266",
        "ufw --force enable",
        "useradd -G sudo -s /usr/bin/zsh -m op",
        "mkdir -p /home/op/.ssh /home/op/.config/",
        "chown -R op:users /home/op",
        "echo 'op:1337superPass' | chpasswd",
        "/bin/su -l op -c 'sh -c \"$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\" \"\" --unattended'",
        "/bin/su -l op -c 'echo \"export PATH=$HOME/bin:/usr/local/bin:$HOME/go/bin:$PATH\" >> ~/.zshrc'",
        "rm /etc/resolv.conf",
        "rm -rf /etc/update-motd.d/*",
        "cp /tmp/configs/sshd_config /etc/ssh/sshd_config",
        "cp /tmp/configs/resolv.conf /etc/resolv.conf",
        "cp /tmp/configs/authorized_keys /home/op/.ssh/authorized_keys",
        "cp /tmp/configs/sudoers /etc/sudoers",
        "chattr +i /etc/resolv.conf",
        "chown -R op:users /home/op",
        "wget -O /tmp/findomain.zip https://github.com/Findomain/Findomain/releases/download/8.2.1/findomain-linux.zip && unzip && mv /tmp/findomain /usr/bin/findomain && chmod +x /usr/bin/findomain",
        "git clone https://github.com/projectdiscovery/nuclei-templates /home/op/recon/nuclei",
        "git clone https://github.com/blechschmidt/massdns.git /tmp/massdns; cd /tmp/massdns; sudo make; sudo mv bin/massdns /usr/bin/massdns",
        "/bin/su -l op -c 'source /home/op/.bashrc'",
        "/bin/su -l op -c 'GO111MODULE=on go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest'",
        "/bin/su -l op -c 'GO111MODULE=on go install -v github.com/tomnomnom/httprobe@latest'",
        "/bin/su -l op -c 'GO111MODULE=on go install -v github.com/ffuf/ffuf@latest'",
        "/bin/su -l op -c 'GO111MODULE=on go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest'",
        "/bin/su -l op -c 'GO111MODULE=on go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest'",
        "/bin/su -l op -c 'GO111MODULE=on go install -v github.com/d3mondev/puredns/v2@latest'",
        "/bin/su -l op -c 'GO111MODULE=on go install -v github.com/lc/gau@latest'",
        "/bin/su -l op -c 'GO111MODULE=on go install -v github.com/tomnomnom/hacks/waybackurls@latest'",
        "/bin/su -l op -c 'GO111MODULE=on go install -v github.com/projectdiscovery/mapcidr/cmd/mapcidr@latest'",
        "/bin/su -l op -c 'GO111MODULE=on go install -v github.com/OWASP/Amass/v3/...@master'",
        "/bin/su -l op -c 'GO111MODULE=on go install -v github.com/OJ/gobuster/v3@latest'",
        "/bin/su -l root -c 'curl -sL https://raw.githubusercontent.com/epi052/feroxbuster/master/install-nix.sh | bash && mv feroxbuster /usr/bin/'",
        "chown -R op:users /home/op",
        "touch /home/op/.profile",
        "chown -R op:users /home/op",
    ]
  }
}

