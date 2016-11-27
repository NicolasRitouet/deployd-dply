# Deployd on [dply](http://dply.co)

[![MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

> Magic button to automatically install and setup Deployd + nginx on [dply](http://dply.co)

[![Dply](https://img.shields.io/badge/dply-Try%20Deployd-green.svg)](https://dply.co/b/0xPk4KNY)

## Getting started

- Click on the dply button [![Dply](https://img.shields.io/badge/dply-Try%20Deployd-green.svg)](https://dply.co/b/0xPk4KNY)
- Login with Github
- Choose server options and select your SSH key
- Start a server
- When the setup is done, the app should be available
- Navigate to the server's IP in your browser, you should see a deployd logo and some text
- ssh into the server to try things out: `ssh root@SERVER_IP`

## Description

This script will:

- install ufw
- install nginx and setup ufw for nginx
- install nodejs
- install mongodb
- install git
- clone an example Deployd app (this same repo)
- start the app using systemd

## Todo

- create a dedicated user for deployd with permissions restricted on the deployd app

## Credits

- [dply.co](http://dply.co) for building this awesome service
- [Dply-POSH](https://github.com/beatcracker/Dply-POSH) for inspiration

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details