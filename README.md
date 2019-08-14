# Thingiverse Migrator
![Push it over there](assets/patrick.jpg)

## Features

* Download your projects from Thingiverse, including most metadata, original images and model files.
* Generate images from stl and scad files so that projects can look nice on sites which do not generate them for you. ([example](assets/render.png))
* Upload your projects to another host (currently only PrusaPrinters supported, and that just barely, see caveats below).

Output example: https://www.prusaprinters.org/social/23599/prints

## Usage

### Project setup

1. Install Docker.

2. Copy `dotenv-dist` to `.env`.

### Back up your Thingiverse data

1. Create a Thingiverse desktop API application: https://www.thingiverse.com/apps/create/  
This will generate an access token, client id and client secret.  
The access token does not have user permissions, and can only access public items.  
<br>If that's all you need, skip to step 2.
    1. If you want to fetch unpublished items as well, you'll need to create an access token for your Thingiverse user.  
  You'll need your client secret from the Thingiverse application you created.
    2. Visit: https://www.thingiverse.com/login/oauth/authorize?client_id=YOUR_CLIENT_SECRET&redirect_uri=http%3A%2F%2Flocalhost%3A9999&response_type=token
    3. Sign in, authorize your application, and copy the `access_token` parameter from the url when you're redirected back to localhost.
2. Run: `bin/run.sh backup <your thingiverse name>`
 This will download your Thingiverse uploads to the `things` directory


### Render images for STL and SCAD files

Some 3D object repositories (like PrusaPrinters.org) do not automatically render STL and SCAD files,
and will instead show a default placeholder image if you do not add your own images.

Optionally, you can generate an image for each project in your `things` directory which does not appear to have an image 
by running:

`bin/run.sh render_objects`

You may instead render all STL and SCAD files by running

`bin/run.sh render_objects --all`

### Migrating uploads to a new location

Currently only PrusaPrinters.org is supported, and that only tentatively.

**WARNING** Uploading to PrusaPrinters has limitations, 
please make sure you understand them before continuing.

### Caveats

1. PrusaPrinters does not support all of the licenses that Thingiverse does. Any projects
you've created which use GPL or BSD licenses will use a Creative Commons license instead (CC BY-SA).
This license is _not_ equivalent.
2. Thingiverse has more categories. I've made some best guesses about how these should map to 
PrusaPrinters' categories. [Pull requests to change this mapping are welcome](lib/prusa/uploader.rb).  
Tags are added as-is, without any translation.
3. You will be prompted to provide your PrusaPrinters.org username and password directly. There is no available
API currently, so all uploads and item creation take place in a headless browser. Your username and password
will not be saved, but the resulting cookies will be. These are created and stored in`cookie_jar/prusa.yml` and 
`cookie_jar/prusa_auth.ym`, and can be deleted when you're done.
4. Because of the lack of an API, the authentication and upload code are very fragile, and
will not be maintained indefinitely.
5. PrusaPrinters' bulleted and ordered list markdown isn't parsed correctly.
6. PrusaPrinters does not have a way to upload inline images for print instruction steps, so these are not handled during
migration.
7. PrusaPrinters uses a different image aspect ratio than Thingiverse, and handles it by cropping to width, which may 
not look ideal for tall images.

#### I understand

Run: `bin/run.sh resore`  
Enter your username and password when prompted.

See `bin/run.sh help restore` for usage and options.
