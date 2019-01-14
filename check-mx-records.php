#!/usr/bin/php -qd display_errors=on
<?php

// Usage
if ($argc >= 2 && ($argv[1] == '-h' || $argv[1] == '--help'))
{
  echo "Usage: check-mx-records.php        Check and report all results\n";
  echo "       check-mx-records.php -q     Check and report only warnings and errors\n";
  echo "       check-mx-records.php -qq    Check and report only errors\n";
  echo "       check-mx-records.php -v     Check and report with debugging information\n";
}

// Options
$debug = ($argc >= 2 && ($argv[1] == '-v'));
$quiet = ($argc >= 2 && ($argv[1] == '-q' || $argv[1] == '-qq'));
$vquiet = ($argc >= 2 && ($argv[1] == '-qq'));

// Load IPs & domain lists
$serverips = explode(' ', `hostname -I`);

if (!array_filter($serverips))
{
  echo "Failed to load server IPs from ifconfig\n";
  exit(1);
}

$ignore = array();
if (file_exists("/etc/check-mx-records-ignore"))
{
  foreach (file("/etc/check-mx-records-ignore") as $mailhost)
  {
    $ignore[] = trim($mailhost);
  }
}

$local = array();
foreach (file("/etc/localdomains") as $mailhost)
{
  $local[] = trim($mailhost);
}

$remote = array();
foreach (file("/etc/remotedomains") as $mailhost)
{
  $remote[] = trim($mailhost);
}

// Messages
function debug($message)
{
  global $debug;
  if ($debug) {
    echo "Debug: $message\n";
  }
}

function ok($message)
{
  global $quiet;
  if (!$quiet)
  {
    echo "[OK] $message\n";
  }
}

function warning($message)
{
  global $vquiet;
  if (!$vquiet)
  {
    echo "[WARNING] $message\n";
  }
}

function error($message)
{
  echo "[ERROR] $message\n";
}

// Go through all domains in cPanel
foreach (glob("/var/cpanel/users/*") as $user)
{
  foreach (file($user) as $line)
  {
    if (preg_match('#^DNS\d*=(.+)$#', $line, $matches))
    {
      list(, $domain) = $matches;
      if (in_array($domain, $ignore))
      {
        warning("Ignored $domain due to listing in /etc/check-mx-records-ignore file");
        continue;
      }
      $esc_domain = escapeshellarg($domain);

      // Handle transient DNS errors - retry 3 times
      for ($i = 1; $i <= 3; $i++)
      {
        if ($i > 1)
        {
          sleep(1);
        }
        debug("Looking up MX record for $domain (attempt $i)...");
        $mailhost = trim(`host -tmx $esc_domain | grep 'is handled by' | sed 's/.*is handled by //' | sort -n | head -1`);
        if ($mailhost)
        {
          break;
        }
      }

      $webip = gethostbyname($domain);
      if ($webip == $domain)
      {
        $wwwdomain = "www.$domain";
        $webip = gethostbyname($wwwdomain);
        if ($webip == $wwwdomain)
        {
          $webip = "NOWHERE";
        }
      }
      if ($mailhost)
      {
        // MX record found
        if (preg_match("#\\d+ (.+)\.#i", $mailhost, $matches))
        {
          list(, $mxdomain) = $matches;
          $mxip = gethostbyname($mxdomain);
          if (!$mxip)
          {
            // Can't resolve the MX record IP
            if (in_array($webip, $serverips))
            {
              error("Invalid MX record for $domain: $mxdomain");
            }
            else
            {
              warning("Invalid MX record for $domain: $mxdomain, but A record for $domain points to external server ($webip) anyway");
            }
          }
          else
          {
            // IP for MX record found
            if (in_array($mxip, $serverips))
            {
              // MX record points to this server
              if (in_array($domain, $local))
              {
                // Mail is correctly handled locally
                if (in_array($webip, $serverips))
                {
                  ok("$domain is handled locally ($mxdomain, $mxip)");
                }
                else
                {
                  warning("$domain is handled locally ($mxdomain, $mxip), but A record for $domain points to external server ($webip) anyway");
                }
              }
              elseif (in_array($domain, $remote))
              {
                // This server thinks the mail is handled externally
                if (in_array($webip, $serverips))
                {
                  error("$domain is handled remotely but MX record points to $mxdomain ($mxip)");
                }
                else
                {
                  warning("$domain is handled remotely but MX record points to $mxdomain ($mxip), but A record for $domain points to external server ($webip) anyway");
                }
              }
              else
              {
                // Not found in either list :S
                if (in_array($webip, $serverips))
                {
                  error("$domain is not found in local or remote files (MX record points to $mxdomain, $mxip)");
                }
                else
                {
                  warning("$domain is not found in local or remote files (MX record points to $mxdomain, $mxip), but A record for $domain points to external server ($webip) anyway");
                }
              }
            }
            else
            {
              if (in_array($domain, $remote))
              {
                // Correctly handled remotely (TODO: Check the remote server matches the MX record?)
                if (in_array($webip, $serverips))
                {
                  ok("$domain is handled remotely ($mxdomain, $mxip)");
                }
                else
                {
                  warning("$domain is handled remotely ($mxdomain, $mxip) but $domain points to $webip");
                }
              }
              elseif (in_array($domain, $local))
              {
                // This server thinks it handles the mail, but it should be going somewhere else
                if (in_array($webip, $serverips))
                {
                  error("$domain is handled locally but MX record points to $mxdomain ($mxip)");
                }
                else
                {
                  warning("$domain is handled locally but MX record points to $mxdomain ($mxip), but A record for $domain points to external server ($webip) anyway");
                }
              }
              else
              {
                // Not found in either list :S
                if (in_array($webip, $serverips))
                {
                  error("$domain is not found in local or remote files (MX record points to $mxdomain, $mxip)");
                }
                else
                {
                  warning("$domain is not found in local or remote files (MX record points to $mxdomain, $mxip), but $domain points to $webip");
                }
              }
            }
          }
        }
        else
        {
          // Don't understand the response from `host`
          if (in_array($webip, $serverips))
          {
            error("Invalid response for $domain: $mailhost");
          }
          else
          {
            warning("Invalid response for $domain: $mailhost, but $domain points to $webip");
          }
        }
      }
      else
      {
        // No MX record exists
        if (in_array($domain, $local))
        {
          // Mail is delivered locally - usually means this is an addon domain's subdomain or a test site
          if (in_array($webip, $serverips))
          {
            warning("MX is missing for $domain");
          }
          else
          {
            warning("MX is missing for $domain, but $domain points to $webip");
          }
        }
        else
        {
          // This server thinks mail should be handled remotely
          if (in_array($webip, $serverips))
          {
            error("$domain is handled remotely but MX is missing");
          }
          else
          {
            warning("$domain is handled remotely but MX is missing, but $domain points to $webip");
          }
        }
      }
    }
  }
}

