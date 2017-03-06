#Stormpath is Joining Okta
We are incredibly excited to announce that [Stormpath is joining forces with Okta](https://stormpath.com/blog/stormpaths-new-path?utm_source=github&utm_medium=readme&utm-campaign=okta-announcement). Please visit [the Migration FAQs](https://stormpath.com/oktaplusstormpath?utm_source=github&utm_medium=readme&utm-campaign=okta-announcement) for a detailed look at what this means for Stormpath users.

We're available to answer all questions at [support@stormpath.com](mailto:support@stormpath.com).

# Vapor Authentication Demo

[![Slack Status](https://talkstormpath.shipit.xyz/badge.svg)](https://talkstormpath.shipit.xyz)

This is a demo for [Vapor](https://vapor.codes)'s authentication using its native [Turnstile](https://github.com/stormpath/Turnstile) integration. This features:

* Username / Password Authentication
* Facebook / Google Login
* API Key authentication for API Endpoints

Want to try it out? [Try out our live example!](https://turnstile-vapor.herokuapp.com)

## Usage

### Install Swift via Swiftenv

If you haven't already, install Swift via [Swiftenv](https://swiftenv.fuller.li/en/latest/).

```bash
$ git clone https://github.com/kylef/swiftenv.git ~/.swiftenv
$ echo 'export SWIFTENV_ROOT="$HOME/.swiftenv"' >> ~/.bash_profile
$ echo 'export PATH="$SWIFTENV_ROOT/bin:$PATH"' >> ~/.bash_profile
$ echo 'eval "$(swiftenv init -)"' >> ~/.bash_profile
```

### Run the Example

```bash
$ swiftenv install
$ swift build
$ .build/debug/App
```

The application should run on port `8080` by default, so you should be able to access it from `http://localhost:8080`

The example code is commented and designed to be readable. Take a look through the code to see what it's doing! 

### Set up Facebook and Google Login

To learn more about Facebook and Google Login, [check out the parent guide in the Turnstile documentation](https://github.com/stormpath/Turnstile#authenticating-with-facebook-or-google). 

#### Create a Facebook Application

To get started, you first need to [register an application](https://developers.facebook.com/?advanced_app_create=true) with Facebook. After registering your app, go into your app dashboard's settings page. Add the Facebook Login product, and save the changes. 

In the `Valid OAuth redirect URIs` box, type in your application's URL, postpended with `/login/facebook/consumer`. (eg, `http://localhost:8080/login/facebook/consumer`)

#### Create a Google Application

To get started, you first need to [register an application](https://console.developers.google.com/project) with Google. Click "Enable and Manage APIs", and then the [credentials tab](https://console.developers.google.com/apis/credentials). Create an OAuth Client ID for "Web".

Add your application's URL, postpended with `/login/facebook/consumer` to the `Authorized redirect URIs` list. (eg, `http://localhost:8080/login/google/consumer`)

#### Add your Client ID / Secret as Environment Variables

This example reads your Facebook and Google Client ID / Secret from environment variables, so you can make it portable. To add it to your application, first collect your Facebook / Google Client ID and Secret (sometimes called App ID), and set them as environment variables:

```bash
$ export FACEBOOK_CLIENT_ID=<Put Client ID here>
$ export FACEBOOK_CLIENT_Secret=<Put Client Secret here>
$ export GOOGLE_CLIENT_ID=<Put Client ID here>
$ export GOOGLE_CLIENT_Secret=<Put Client Secret here>
```

This is also possible in Xcode under `Edit Scheme > Arguments > Environment Variables`. 

Now run the application. Facebook and Google login should work! 

*Note: Facebook / Google Login are broken in Swift 3.0 on Linux, because of a Foundation bug. This demo should work in `DEVELOPMENT-SNAPSHOT-2016-09-14-a` or later, or in the official 3.0.1 release (not PREVIEW-1).*

# Contributing

We're always open to contributions! Feel free to join the [Stormpath slack channel](https://talkstormpath.shipit.xyz) to discuss how you can contribute!

# Stormpath

Turnstile is built by [Stormpath](https://stormpath.com), an API service for authentication, authorization, and user management. If you're building a website, API, or app, and need to build authentication and user management, consider using Stormpath for your needs. We're always happy to help!
