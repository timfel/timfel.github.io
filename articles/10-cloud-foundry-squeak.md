date: 2012-02-22
title: CloudFoundry for Smalltalk applications

## Finally!

After [James Foster](http://programminggems.wordpress.com/)
[posted](http://programminggems.wordpress.com/2012/02/17/adding-smalltalk-to-cloud-foundry/)
about getting [Aida](http://www.aidaweb.si/download) running on
[CloudFoundry](http://cloudfoundry.com/), I just *had* to give it a go.

The first step was installing CloudFoundry. I created a `vcap` user on
the server to run the cloud services. Using the `dev_setup` script
from
[https://github.com/cloudfoundry/vcap/](https://github.com/cloudfoundry/vcap/)
got me up and running in just under an hour. The installer will
download a few packages (it needs sudo for this) and then install all
the runtimes (i.e. language VMs) and frameworks as the local
user. Afterwards, the websites hosted here were broken, because
there's another thing that the installer changes, and that is your
`nginx.conf`. By default, it'll redirect everything to the
CloudFoundry router process, which is not what I wanted. I just
changed it to only redirect anything under `*.vcap.bithug.org` to the
router, so all other websites could work as previously.

The last thing the installer told you was, how to run the cloud:
    ~/cloudfoundry/vcap/dev_setup/bin/vcap_dev start
I found that, since we have a global RVM setup on this server, this
interfered with the local rvm install the cloud foundry script set up,
so I changed the .bashrc of this user to not load RVM and only use
this minimal `PATH`

[bashrc](//gist.github.com/1886224)

After starting, I tested the setup with this simple Sinatra app:

[env.rb](//gist.github.com/1886224)

To do this, I needed to create a user on the server, using the vmc
script.
    vmc adduser
Afterwards, it might be a good idea to change
`~/cloudfoundry/.deployments/dev_box/config/cloud_controller.yml`,
insert your own email address into the list of admin users and
disallow registering users through vmc. This way, only you'll be able
to add new users.

With this out of the way, we can just put the Sinatra app in an empty
directory and run
    vmc push
It will ask a series of questions, I accepted the defaults after
choosing *env* as the name for my app. I verified that it worked by
going to [http://env.vcap.bithug.org](http://env.vcap.bithug.org).

#### Smalltalk, the Server Side

Now, the good stuff :) For getting Smalltalk to run, I pretty much
followed James'
[instructions](http://programminggems.wordpress.com/2012/02/17/adding-smalltalk-to-cloud-foundry/).
But I wasn't interested in Aida. For my master's thesis, I will need a
few small apps running under different URLs. For one of those apps,
I'll be using Smalltalk apps written in a tiny web library called
[RatPack](http://ss3.gemstone.com/ss/RatPack.html) (yes, it's a
Sinatra look-alike in Smalltalk - even the error page is copied). So I
needed a way to run arbitrary Smalltalk apps.

To do this, I changed James' instructions to define a `Squeak`, rather
than a `Aida` framework. While I was at it, I also changed a few other things:

* I use the latest CogVM builds from [Eliot
  Miranda](http://www.mirandabanda.org/)'s website.
* I install a patch during staging that will mirror the Transcript to
  a logfile, so you can have 'some' debugging
* I installed the smalltalk services stuff in the `vcap` user's home
  directory

You can grab the complete patch
[here](https://github.com/timfel/vcap/commit/dcd2469d0738af05315495a413db736f8aa97b76).

Because CloudFoundry assigns a random port to its apps, I used James'
solution of passing the `$VCAP_APP_PORT` as a commandline argument for
the Squeak application to use. However, because I don't know what the
app is going to look like, the developer will have to make sure that
his/her app honors that argument.

#### Smalltalk, the Smalltalk Side

Now I created a (very simple) RatPack application:

[app.st](//gist.github.com/1886415)

Usually, with RatPack, you will use the Morphic control panel to start
applications, assign them a port and so on. On CloudFoundry, the cloud
controller might start an image on any port it chooses, or run
multiple instances in parallel. To make sure our application is always
running on the right port, I added these methods to the *class side*
of the `TestApp` class:

[classside.st](//gist.github.com/1886415)

This will make sure the application is properly shutdown and restarted
whenever an image is stopped and re-run.

Now, to push this to the cloud, we need a `squeak.st` script that
creates our initial image. To make this step fast and easy, I created
a small [project](http://ss3.gemstone.com/ss/CloudFoundry.html) to
create `pushable` directories and scripts from your
applications. Install it and run:

[script.st](//gist.github.com/1886415)

It asks whether you want to install any _MetacelloConfigurations_
and/or _MCZs_. I chose `ConfigurationOfRatPack` in version 1.0 with
the default group, as well as my TestApp MCZ. The script creates a
folder named `vmc` in your default Smalltalk directory with two MCZs
copied from your `package-cache`, as well as a `squeak.st` script to
run during the staging process:

[squeak.st](//gist.github.com/1886415)

As you can see, this script will install the configuration and the
mcz, as well as the RFB server, so you can connect to your image via
VNC for debugging.

To actually push this application, again follow James'
[instructions](http://programminggems.wordpress.com/2012/02/14/preparing-smalltalk-for-cloud-foundry/)
to patch the vmc gem on your development machine (second to last
paragraph, adjust it so it reads `squeak` instead of `aida` in all
places).

With that done, it's as easy as going into the `vmc` directory and
running `vmc push`. It should recognize that you're working with a
Squeak application and ask for deployment details.

In my case, because Squeak actually has to load quite a few things
during staging, the client then timed out and reported a failure. You
can check the transcript logfile or with VNC to make sure everything
works as expected. Once you got it working, use 

[deploy.st](//gist.github.com/1886415)

to generate a deployment without VNC access to lock down your image.

Go say thanks to [James](http://programminggems.wordpress.com/) and
[Peter](http://maglevity.wordpress.com/about/) for doing the hard work
and finding all that out!
