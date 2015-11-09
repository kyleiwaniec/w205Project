
# Python 2.7.6 (this was already done):
wget http://python.org/ftp/python/2.7.6/Python-2.7.6.tar.xz
tar xf Python-2.7.6.tar.xz
cd Python-2.7.6
./configure --prefix=/usr/local --enable-unicode=ucs4 --enable-shared LDFLAGS="-Wl,-rpath /usr/local/lib"
make && make altinstall
 
# Python 3.3.5:
wget http://python.org/ftp/python/3.3.5/Python-3.3.5.tar.xz
tar xf Python-3.3.5.tar.xz
cd Python-3.3.5
./configure --prefix=/usr/local --enable-shared LDFLAGS="-Wl,-rpath /usr/local/lib"
make && make altinstall





These steps were taken to activate the 2.7 environment, and not break shit like yum

wget https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py
python2.7 ez_setup.py
easy_install-2.7 pip
pip2.7 install virtualenv
virtualenv -p python2.7 27env
source 27env/bin/activate

sudo yum install libxml2 libxml2-dev libxslt-devel python-dev python-setuptools
sudo yum groupinstall "Development Tools"
sudo yum install python2-devel libffi-devel openssl-devel
pip2.7 install Scrapy



pip2.7 list
cffi (1.3.0)
characteristic (14.3.0)
cryptography (1.1)
cssselect (0.9.1)
enum34 (1.0.4)
idna (2.0)
ipaddress (1.0.14)
lxml (3.4.4)
ordereddict (1.1)
pip (7.1.2)
pyasn1 (0.1.9)
pyasn1-modules (0.0.8)
pycparser (2.14)
pyOpenSSL (0.15.1)
queuelib (1.4.2)
Scrapy (1.0.3)
service-identity (14.0.0)
setuptools (18.2)
six (1.10.0)
Twisted (15.4.0)
w3lib (1.13.0)
wheel (0.24.0)
zope.interface (4.1.3)


python
>>> import cffi
>>> import characteristic
>>> import cryptography
>>> import cssselect
>>> import enum34
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
ImportError: No module named enum34
>>> import enum
>>> import idna
>>> import ipaddress
>>> import lxml
>>> import ordereddict
>>> import pyasn1
>>> import pycparser
>>> import pyOpenSSL
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
ImportError: No module named pyOpenSSL
>>> import queuelib
>>> import Scrapy
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
ImportError: No module named Scrapy
>>> import scrapy
>>> import service-identity
  File "<stdin>", line 1
    import service-identity
                  ^
SyntaxError: invalid syntax
>>> import service_identity
>>> import six
>>> import Twisted
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
ImportError: No module named Twisted
>>> import twisted
>>> import w3lib
>>> import wheel
>>> import zope.interface

# to switch back to python2.6:
deactivate