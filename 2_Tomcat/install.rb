package 'java-1.7.0-openjdk-devel'
group 'tomcat' do
end
user 'tomcat' do
        home '/opt/tomcat'
        group 'tomcat'
        shell '/bin/nologin'
end

#bash "download_tomcat" do
#       user "root"
#       cd ~
#       wget http://mirror.metrocast.net/apache/tomcat/tomcat-8/v8.5.34/bin/apache-tomcat-8.5.34.tar.gz
#       tar -zxvf apache-tomcat-8.0.33.tar.gz -C /opt/tomcat --strip-components=1

remote_file '/tmp/tomcat.gz' do
        source 'http://mirror.metrocast.net/apache/tomcat/tomcat-8/v8.5.34/bin/apache-tomcat-8.5.34.tar.gz'
end

directory '/opt/tomcat'

execute 'unzip' do
        cwd '/tmp'
        command 'tar -zxvf tomcat.gz -C /opt/tomcat --strip-components=1'
end

#directory resource permissions are not recursive
execute 'update permissions recursivley' do
        user "root"
        cwd '/opt/tomcat'
        command 'chgrp -R tomcat /opt/tomcat;chown -R /opt/tomcat tomcat;chgrp -R tomcat conf;chmod g+rwx conf/*; chmod g+r conf/*;chown -R tomcat logs/ temp/ webapps/ work/; chgrp -R tomcat bin; chgrp -R tomcat lib;chmod g+twx bin;chmod g+r bin/*;'
end


systemd_unit 'tomcat.service' do
content '
[Unit]
Description=Apache Tomcat Web Application Container
After=syslog.target network.target

[Service]
Type=forking

Environment=JAVA_HOME=/usr/lib/jvm/jre
Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat
Environment=\'CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC\'
Environment=\'JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom\'

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/bin/kill -15 $MAINPID

User=tomcat
Group=tomcat

[Install]
WantedBy=multi-user.target'

action [:create, :start, :enable]
triggers_reload true

end

http_request 'wget' do
        url 'http://localhost:8080'
end
