# Server configuration code samples

Use the code samples below to configure your server when working with WebGL
. The following samples apply to Nginx, Apache, and IIS servers. For further information on WebGL server configuration,

## Server configuration for WebGL builds (Nginx)
```
http {
# ...

server {
# Add the following config within http server configuration
# ...
 
# On-disk Brotli-precompressed data files should be served with compression enabled:
location ~ .+\.(data|symbols\.json)\.br$ {
    # Because this file is already pre-compressed on disk, disable the on-demand compression on it.
    # Otherwise nginx would attempt double compression.
    gzip off;
    add_header Content-Encoding br;
    default_type application/octet-stream;
}

# On-disk Brotli-precompressed JavaScript code files:
location ~ .+\.js\.br$ {
    gzip off; # Do not attempt dynamic gzip compression on an already compressed file
    add_header Content-Encoding br;
    default_type application/javascript;
}

# On-disk Brotli-precompressed WebAssembly files:
location ~ .+\.wasm\.br$ {
    gzip off; # Do not attempt dynamic gzip compression on an already compressed file
    add_header Content-Encoding br;
    # Enable streaming WebAssembly compilation by specifying the correct MIME type for
    # Wasm files.
    default_type application/wasm;
}

# On-disk gzip-precompressed data files should be served with compression enabled:
location ~ .+\.(data|symbols\.json)\.gz$ {
    gzip off; # Do not attempt dynamic gzip compression on an already compressed file
    add_header Content-Encoding gzip;
    default_type application/gzip;
}

# On-disk gzip-precompressed JavaScript code files:
location ~ .+\.js\.gz$ {
    gzip off; # Do not attempt dynamic gzip compression on an already compressed file
    add_header Content-Encoding gzip; # The correct MIME type here would be application/octet-stream, but due to Safari bug https://bugs.webkit.org/show_bug.cgi?id=247421, it's preferable to use MIME Type application/gzip instead.
    default_type application/javascript;
}

# On-disk gzip-precompressed WebAssembly files:
location ~ .+\.wasm\.gz$ {
    gzip off; # Do not attempt dynamic gzip compression on an already compressed file
    add_header Content-Encoding gzip;
    # Enable streaming WebAssembly compilation by specifying the correct MIME type for
    # Wasm files.
    default_type application/wasm;
}
}
}
````

## Server configuration for WebGL builds (Apache)
You can configure WebGL builds in Apache using one of the two methods: Virtual Host in httpd.conf, or .htaccess. Unity recommends configuring a virtual host in Apache’s httpd.conf, if you have access to that configuration.

To configure WebGL builds using the Virtual Host in ``httpd.conf`` method:

```
<Directory /var/www/html/root/path/to/your/unity/content/>
<IfModule mod_mime.c>
RemoveType .gz
AddEncoding gzip .gz
# The correct MIME type for .data.gz would be application/octet-stream, but due to Safari bug https://bugs.webkit.org/show_bug.cgi?id=247421, it is preferable to use MIME Type application/gzip instead.
#AddType application/octet-stream .data.gz
AddType application/gzip .data.gz
AddType application/wasm .wasm.gz
AddType application/javascript .js.gz
AddType application/octet-stream .symbols.json.gz

RemoveType .br
AddEncoding br .br
AddType application/octet-stream .data.br
AddType application/wasm .wasm.br
AddType application/javascript .js.br
AddType application/octet-stream .symbols.json.br

</IfModule>
</Directory>

```

### Server configuration for compressed WebGL builds without decompression fallback (IIS)

```
<?xml version="1.0" encoding="UTF-8"?>
<!--
 The following server configuration can be used for compressed WebGL builds without decompression fallback.
 This configuration file should be uploaded to the server as "<Application Folder>/Build/web.config".

NOTE: To host compressed WebGL builds without decompression fallback, you need to install the "URL Rewrite" IIS module on the server.
Otherwise, IIS will throw an exception when using this configuration file.
This module is available at https://www.iis.net/downloads/microsoft/url-rewrite.
-->


<configuration>
 <system.webServer>
   <!--
     Compressed Unity builds without decompression fallback can't be properly hosted on a server which
     has static compression enabled because this might result in the build files being compressed twice.
     The following line disables static server compression.
   -->
   <urlCompression doStaticCompression="false" />
   <!-- To host compressed Unity builds, the correct mimeType should be set for the compressed build files. -->
   <staticContent>
     <!--
       NOTE: IIS will throw an exception if a mimeType is specified multiple times for the same extension.
       To avoid possible conflicts with configurations that are already on the server, you should remove the mimeType for the corresponding extension using the <remove> element,
       before adding mimeType using the <mimeMap> element.
     -->
     <!-- The following lines are required for builds compressed with gzip, which don't include decompression fallback. -->
     <remove fileExtension=".data.gz" />
     <mimeMap fileExtension=".data.gz" mimeType="application/gzip" /><!-- The correct MIME type here would be application/octet-stream, but due to Safari bug https://bugs.webkit.org/show_bug.cgi?id=247421, it's preferable to use MIME Type application/gzip instead. -->
     <remove fileExtension=".wasm.gz" />
     <mimeMap fileExtension=".wasm.gz" mimeType="application/wasm" />
     <remove fileExtension=".js.gz" />
     <mimeMap fileExtension=".js.gz" mimeType="application/javascript" />
     <remove fileExtension=".symbols.json.gz" />
     <mimeMap fileExtension=".symbols.json.gz" mimeType="application/octet-stream" />
     <!-- The following lines are required for builds compressed with Brotli, which don't include decompression fallback. -->
     <remove fileExtension=".data.br" />
     <mimeMap fileExtension=".data.br" mimeType="application/octet-stream" />
     <remove fileExtension=".wasm.br" />
     <mimeMap fileExtension=".wasm.br" mimeType="application/wasm" />
     <remove fileExtension=".js.br" />
     <mimeMap fileExtension=".js.br" mimeType="application/javascript" />
     <remove fileExtension=".symbols.json.br" />
     <mimeMap fileExtension=".symbols.json.br" mimeType="application/octet-stream" />
   </staticContent>

   <!--
     Hosting compressed Unity builds without decompression fallback relies on native browser decompression,
     therefore a proper "Content-Encoding" response header should be added for the compressed build files.
     NOTE: IIS will throw an exception if the following section is used without the "URL Rewrite" module installed.
     Download the "URL Rewrite" module from https://www.iis.net/downloads/microsoft/url-rewrite
   -->
   <rewrite>
     <outboundRules>
       <!--
         NOTE: IIS will throw an exception if the same rule name is used multiple times.
         To avoid possible conflicts with configurations that are already on the server, you should remove the mimeType for the corresponding extension using the <remove> element,
       before adding mimeType using the <mimeMap> element.
       -->
       <!-- The following section is required for builds compressed with gzip, which don't include decompression fallback. -->
       <remove name="Append gzip Content-Encoding header" />
       <rule name="Append gzip Content-Encoding header">
         <match serverVariable="RESPONSE_Content-Encoding" pattern=".*" />
         <conditions>
           <add input="{REQUEST_FILENAME}" pattern="\.gz$" />
         </conditions>
         <action type="Rewrite" value="gzip" />
       </rule>
       <!-- The following section is required for builds compressed with Brotli, which don't include decompression fallback. -->
       <remove name="Append brotli Content-Encoding header" />
       <rule name="Append brotli Content-Encoding header">
         <match serverVariable="RESPONSE_Content-Encoding" pattern=".*" />
         <conditions>
           <add input="{REQUEST_FILENAME}" pattern="\.br$" />
         </conditions>
         <action type="Rewrite" value="br" />
       </rule>
     </outboundRules>
   </rewrite>
 </system.webServer>
</configuration>
```

## Server configuration for uncompressed WebGL builds (IIS)

```
<?xml version="1.0" encoding="UTF-8"?>
<!--
 The following server configuration can be used for uncompressed WebGL builds.
 This configuration file should be uploaded to the server as "<Application Folder>/Build/web.config"
-->
<configuration>
 <system.webServer>
   <!--
     IIS does not provide default handlers for .data and .wasm files (and in some cases .json files),
     therefore these files won’t be served unless their mimeType is explicitly specified.
   -->
   <staticContent>
     <!--
       NOTE: IIS will throw an exception if a mimeType is specified multiple times for the same extension.
       To avoid possible conflicts with configurations that are already on the server, you should remove the mimeType for the corresponding extension using the <remove> element,
       before adding mimeType using the <mimeMap> element.
     -->
     <remove fileExtension=".data" />
     <mimeMap fileExtension=".data" mimeType="application/octet-stream" />
     <remove fileExtension=".wasm" />
     <mimeMap fileExtension=".wasm" mimeType="application/wasm" />
     <remove fileExtension=".symbols.json" />
     <mimeMap fileExtension=".symbols.json" mimeType="application/octet-stream" />
   </staticContent>
 </system.webServer>
</configuration>


```