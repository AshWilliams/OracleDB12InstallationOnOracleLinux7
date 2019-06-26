# Install Oracle 12C Release 2 (12.2) on Oracle Linux 7 (OEL7)

This article presents how to install Oracle 12C(12.2) Release 2 on Oracle Enterprise Linux 7 (OEL7).

Read following article how to install Oracle Enterprise Linux 7: [Install Oracle Linux 7 (OEL7)](http://dbaora.com/install-oracle-linux-7/ "Install Oracle Linux 7 (OEL7)") (for comfort set 4G memory for your virtual machine before proceeding with Oracle software installation).

Software for 12CR2 is available on OTN or edelivery

*   [OTN: Oracle Database 12c Release 2 (12.2.0.1) Software (64-bit)](http://www.oracle.com/technetwork/database/enterprise-edition/downloads/index.html)
*   [edelivery: Oracle Database 12c Release 1 (12.2.0.1) Software (64-bit)](http://edelivery.oracle.com)

Database software

    linuxx64_12201_database.zip


OS configuration and preparation

OS configuration is executed as root. To login as root just execute following command in terminal.

    su - root

The `/etc/hosts` file must contain a fully qualified name for the server.

    <IP-address>  <fully-qualified-machine-name>  <machine-name>    

For example.

    127.0.0.1 oel7 oel7.dbaora.com localhost.localdomain localhost

Set hostname

    hostnamectl set-hostname oel7.dbaora.com --static    

Add groups

    #groups for database management
    groupadd -g 54321 oinstall
    groupadd -g 54322 dba
    groupadd -g 54323 oper
    groupadd -g 54324 backupdba
    groupadd -g 54325 dgdba
    groupadd -g 54326 kmdba
    groupadd -g 54327 asmdba
    groupadd -g 54328 asmoper
    groupadd -g 54329 asmadmin
    groupadd -g 54330 racdba    

###### Add user Oracle for database software

    useradd -u 54321 -g oinstall -G dba,oper,backupdba,dgdba,kmdba,racdba oracle    

Change password for user Oracle

    passwd oracle    



Check which packages are installed and which are missing

    rpm -q --qf '%{NAME}-%{VERSION}-%{RELEASE}(%{ARCH})\n' binutils \
compat-libcap1 \
compat-libstdc++-33 \
glibc \
glibc-devel \
ksh \
libaio \
libaio-devel \
libX11 \
libXau \
libXi \
libXtst \
libgcc \
libstdc++ \
libstdc++-devel \
libxcb \
make \
nfs-utils \
smartmontools \
net-tools \
sysstat    

You can install missing packages from dvd. Just mount it and install missing packages using rpm -Uvh command from directory <mount dvd>/Packages or by using yum install command.

NOTE – I’m using x86_64 version of packages

First option from dvd

    rpm -Uvh libaio-devel*.x86_64.rpm
    rpm -Uvh ksh*.x86_64.rpm    

Second option using yum install command. It requires access to internet.

    yum install libaio-devel*.x86_64
    yum install ksh*.x86_64    

Add kernel parameters to /etc/sysctl.conf

    # kernel parameters for 12gR2 installation

    fs.file-max = 6815744
    kernel.sem = 250 32000 100 128
    kernel.shmmni = 4096
    kernel.shmall = 1073741824
    kernel.shmmax = 4398046511104
    net.core.rmem_default = 262144
    net.core.rmem_max = 4194304
    net.core.wmem_default = 262144
    net.core.wmem_max = 1048576
    fs.aio-max-nr = 1048576
    net.ipv4.ip_local_port_range = 9000 65500
    kernel.panic_on_oops=1  

Apply kernel parameters

    /sbin/sysctl -p    

Add following lines to set shell limits for user oracle in file /etc/security/limits.conf

    # shell limits for users oracle 12gR2

    oracle   soft   nofile   1024
    oracle   hard   nofile   65536
    oracle   soft   nproc    2047
    oracle   hard   nproc    16384
    oracle   soft   stack    10240
    oracle   hard   stack    32768
    oracle   soft   memlock  3145728
    oracle   hard   memlock  3145728    

Disable firewall

    service iptables stop
    chkconfig iptables off    

Additional steps

Add following lines in .bash_profile for user oracle

    # Oracle Settings
    export  TMP=/tmp

    export  ORACLE_HOSTNAME=oel7.dbaora.com
    export  ORACLE_UNQNAME=ORA12C
    export  ORACLE_BASE=/ora01/app/oracle
    export  ORACLE_HOME=$ORACLE_BASE/product/12.2.0/db_1
    export  ORACLE_SID=ORA12C

    PATH=/usr/sbin:$PATH:$ORACLE_HOME/bin

    export  LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib;
    export  CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib;

    alias cdob='cd $ORACLE_BASE'
    alias cdoh='cd $ORACLE_HOME'
    alias tns='cd $ORACLE_HOME/network/admin'
    alias envo='env | grep ORACLE'

    umask 022

    if [ $USER = "oracle" ]; then
     if [ $SHELL = "/bin/ksh" ]; then
       ulimit -u 16384 
       ulimit -n 65536
     else
       ulimit -u 16384 -n 65536
     fi
    fi

    envo    

Directory structure

Create directory structure as user root

ORACLE_BASE – /ora01/app/oracle

ORACLE_HOME – /ora01/app/oracle/product/12.2.0/db_1

    mkdir -p /ora01/app/oracle/product/12.2.0/db_1
    chown oracle:oinstall -R /ora01    

“OPTIONAL” – In Oracle Enterprise Linux 7 /tmp data is stored on tmpfs which consumes memory and is too small. To revert it back to storage just run following command and REBOOT machine to be effective.

    systemctl mask tmp.mount    

  

######Install database software

Let’s start with database software installation as oracle user. Usually I’m connected as user root in GNOME so you need to use ssh.

Connect as user oracle

    [root@oel7 ~]# ssh oracle@oel7.dbaora.com -X    

Let’s start with database software installation as oracle user.

    --unizp software it will create directory "database" 
--where you can find installation software

    unzip linuxx64_12201_database.zip

--I defined 4 aliases in .bash_profile of user oracle to make 
--administration easier :)

        [oracle@oel7 ~]$ alias envo cdob cdoh tns
    alias envo='env | grep ORACLE'
    alias cdob='cd $ORACLE_BASE'
    alias cdoh='cd $ORACLE_HOME'
    alias tns='cd $ORACLE_HOME/network/admin'

--run alias command envo to display environment settings
    envo
    ORACLE_UNQNAME=ORA12C
    ORACLE_SID=ORA12C
    ORACLE_BASE=/ora01/app/oracle
    ORACLE_HOSTNAME=oel7.dbaora.com
    ORACLE_HOME=/ora01/app/oracle/product/12.2.0/db_1

--run alias command cdob and cdoh 
--to check ORACLE_BASE, ORACLE_HOME 
    [oracle@oel7 ~]$ cdob
    [oracle@oel7 oracle]$ pwd
    /ora01/app/oracle

    [oracle@oel7 db_1]$ cdoh
    [oracle@oel7 db_1]$ pwd
     /ora01/app/oracle/product/12.2.0/db_1

--run installation from "database" directory
    ./runInstaller    

1\. Uncheck checkbox “I wish to receive security updates via My Oracle Support” and then click “Next” button.

[![](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_1.png)](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_1.png)

2\. Ignore following message and click “Yes” button.

[![](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_2.png)](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_2.png)

3\. Select “Create and configure a database” then click “Next” button.

[![](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_3.png)](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_3.png)

4\. Select “Server class” and click “Next” button.

[![](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_4.png)](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_4.png)

5\. Accept default “Single instance database installation” and click “Next” button.

[![](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_5.png)](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_5.png)

6\. Select “Advanced install” to later select more options during database installation and click “Next” button.

[![](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_6.png)](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_6.png)

7\. You can select here type of binaries to install. Once it’s done click “Next” button.

[![](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_7.png)](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_7.png)

8\. Here you should see directories for ORACLE_BASE and ORACLE_HOME for your binaries according to environmental settings. Click “Next” button.

[![](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_8.png)](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_8.png)

9\. Accept default and click “Next” button.

[![](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_9.png)](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_9.png)

10\. Accept default “General Purpose/ transaction Processing” and click “Next” button.

[![](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_10.png)](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_10.png)

11\. Check checkbox “Create as Container database” and enter “Pluggable database name” to add your first container database ORA12C and pluggable database PORA12C1, click “Next” button.

[![](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_11.png)](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_11.png)

12\. Specify more details about your database on 3 tabs where you can define memory settings, character set and if to install sample schema on your database. Once you are happy with your settings click “Next” button.

[![](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_12.png)](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_12.png) [![](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_13.png)](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_13.png) [![](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_14.png)](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_14.png)

13\. Specify directory where you want to install your database files then click “Next” button.

[![](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_15.png)](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_15.png)

14\. On this page you can register your database in Oracle Enterprise Manager”. Accept default settings and click “Next” button.

[![](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_16.png)](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_16.png)

15\. Check checkbox “Enable Recovery” to specify directory for your recovery area “Recovery area location” and click “Next” button.

[![](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_17.png)](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_17.png)

16\. Specify password for each user or enter the same for all. Once it’s done click “Next” button.

[![](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_18.png)](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_18.png)

17\. Here you can specify OS group for each oracle group. Accept default settings and click “Next” button.

[![](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_19.png)](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_19.png)

18\. Checks are started to verify if OS is ready to install database software.

[![](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_20.png)](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_20.png)

19\. If everything is right click “Install” button. It’s the last moment to come back to each of previous point and make changes.

[![](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_21.png)](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_21.png)

20\. Installation in progress … go play FIFA on PS4 :p

[![](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_22.png)](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_22.png)

21\. Once binaries are installed the last step is to run 2 scripts as user root.

[![](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_23.png)](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_23.png)

    --execute scripts
    /ora01/app/oraInventory/orainstRoot.sh
    /ora01/app/oracle/product/12.2.0/db_1/root.sh    

Second script enables to install Oracle Trace File Analyzer (TFA). It’s worth to install it.

23\. Installation will continue … but suddenly error occurred

[![](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_24.png)](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_24.png)

[![](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_25.png)](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_25.png)

It was problem with listener. I had to start it manually. Once LISTENER is started click “Retry” button and installation should continue

        [oracle@oel7 ~]$ lsnrctl start    

[![](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_26.png)](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_26.png)

24\. You are lucky 12C installation is completed. Click “Close” button.

[![](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_27.png)](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_27.png)

25.Another summary with information about “Enterprise manager database express”

[![](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_28.png)](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_28.png)

26\. Try to login as SYS to Enterprise manager Database express 12C .

NOTE – It requires to install flash plug-in and running listener. In addition don’t provide container name to connect.

https://oel7.dbaora.com:5500/em

[![](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_29.png)](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_29.png) [![](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_30.png)](http://dbaora.com/wp-content/uploads/2017/03/oracle_db122c_30.png)

27\. Try to connect to container database as user SYS using sqlplus tool

        [oracle@oel7 ~]$ sqlplus / as sysdba

SQL*Plus: Release 12.2.0.1.0 Production on Thu Mar 23 15:51:38 2017

Copyright (c) 1982, 2016, Oracle.  All rights reserved.

Connected to:
Oracle Database 12c Enterprise Edition Release 12.2.0.1.0 - 64bit 
Production

SQL>    

<span style="text-decoration: underline;">Problems</span>

In release 12.2.0.1 following bugs can be encountered

1.  Problem with LISTNER. It doesn’t started and DBCA recognized it as bug.

Have a fun 🙂

