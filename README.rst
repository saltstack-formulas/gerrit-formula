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

Install and configure gerrit.

``gerrit.service``
----------

Start up gerrit service.

For a list of all available options, look at: `gerrit/defaults.yaml` - also have a look at the pillar.example and map.jinja.

Mandatory pillars
=================

Pillars **serverId** and **registerEmailPrivateKey** are mandatory,
because if unset, ``gerrit init`` will generate them
for you, but then SaltStack will remove them from the config file during the next run.

Structure example:

.. code:: yaml

 gerrit:
   config:
     gerrit:
       serverId: myUniqueServerId
   secure:
     auth:
       registerEmailPrivateKey: 'generate me by "openssl rand -base64 36"'

Currently tested under:
=======================

* Debian 8.3 Jessie
* Ubuntu 14.04 LTS
* CentOS 7

Testing
=======

Not yet done.
