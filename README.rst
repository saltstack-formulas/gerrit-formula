gerrit
======

Formula to install and configure gerrit.

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

Available states
================

.. contents::
    :local:

``gerrit``
----------

Install gerrit and start up the gerrit service.

Currently tested under:

* Debian 8.3 Jessie
* Ubuntu 14.04 LTS
* CentOS 7

For a list of all available options, look at: `gerrit/defaults.yaml` - also have a look at the pillar.example and map.jinja.

Obligatory pillar
=================

Pillar **registerEmailPrivateKey** is mandatory because if you do not generate it gerrit init will generate it
for you but then saltstack will remove it from config file during next run.

The one of the ways to do it use command **openssl rand -base64 36**

Structure example:

.. code:: yaml

 gerrit:
   secure:
     auth:
       registerEmailPrivateKey: 'generate me by "openssl rand -base64 36"'

Testing
=======

Not yet done.
