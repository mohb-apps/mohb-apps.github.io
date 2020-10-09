#!/usr/bin/perl

#
#  File          : buildPages.pl
#  Last modified : 06/17/20 6:55 PM
#
#  Developer     : Haraldo Albergaria Filho, a.k.a. mohb apps
#
#  Description   : Script to create mohb apps website
#  Usage         : buildPages.pl
#
#  --------------------------------------------------------------

my $pages_root_path     = "../";
my $root_index_file     = "index.html";
my $br_index_file       = "br/index.html";
my $tools_index_file    = "tools/index.html";
my $br_tools_index_file = "br/tools/index.html";
my $projects_path       = "../../../AndroidStudioProjects";

chdir $pages_root_path;

# Check if there is a br index file and finish script if not
if (not -f $br_index_file) {
  die "There is no br/index.html file! Please, create one and run again.\n";
}

# Check if there is a br tools index file and finish script if not
if (not -f $br_tools_index_file) {
  die "There is no br/tools/index.html file! Please, create one and run again.\n";
}


# Extract apps names and directories from root index file

open ROOT_INDEX, "$root_index_file" or die "Can't open $root_index_file to read: $!\n";
my @index_file_lines = <ROOT_INDEX>;
close ROOT_INDEX;

my @apps;
my @apps_proj_dirs;
my @apps_site_dirs;

foreach (@index_file_lines) {
  if ( m/<a\shref=\"https:\/\/mohb-apps\.github\.io\/apps\/.+\/\">(.+)<\/a>[^<]/ ) {
    push(@apps, $1);
  }
}

foreach (@apps) {
  $proj_dir = $_;
  $site_dir = $_;
  $proj_dir =~ s/\s//g;
  $site_dir =~ s/\s/-/g;
  $site_dir = lc $site_dir;
  push(@apps_proj_dirs, $proj_dir);
  push(@apps_site_dirs, $site_dir);
}


# Extract menu from root index file

my $copy = 0;
my @menu;

foreach (@index_file_lines) {
  if ( m/<!--\sTop Menu\s-->/ ) {
    $copy = 1;
  }
  if ($copy == 1) {
    push (@menu, $_);
  }
  if ( m/<!--\send\s-->/ ) {
    $copy = 0;
  }
}


# Extract Statcounter code from index file

my $copy = 0;
my @stats_code;

foreach (@index_file_lines) {
  if ( m/<!--\sDefault\sStatcounter\scode/ ) {
    $copy = 1;
  }
  if ($copy == 1) {
    push (@stats_code, $_);
  }
  if ( m/<!--\sEnd\sof\sStatcounter\sCode/ ) {
    $copy = 0;
  }
}


# Create br menu

my @br_menu = @menu;

foreach (@br_menu) {
  s/contact/contato/g;
  s/.io\//.io\/br\//g;
  s/br\/br\///g;
  s/portuguese.png/english.png/g;
  s/title="ver\sem\sportuguês"/title="view in english"/g;
  s/title="send\sa\smessage"/title="envie uma mensagem"/g;
  s/title="development\stools"/title="ferramentas de desenvolvimento"/g;
  s/alt="home"/alt="início"/g;
  s/alt="apps"/alt="aplicativos"/g;
  s/alt="tools"/alt="ferramentas"/g;
  s/alt="português"/alt="english"/g;
}


# Update menu and stats code on root tools page

my @tools_menu = @menu;

open TOOLS_INDEX, "$tools_index_file" or die "Can't open $tools_index_file to read: $!\n";
my @tools_index_file_lines = <TOOLS_INDEX>;
close TOOLS_INDEX;

my @temp;
my $copy = 1;
my $stop = 0;

foreach (@tools_index_file_lines) {
  if ( m/<!--\sDefault\sStatcounter\scode/ ) {
    $copy = 0;
    while ($stop == 0) {
      $last = pop @temp;
      if ($last =~ /<\/div>/) {
        push @temp, $last;
        push @temp, "\n";
        $stop = 1;
      }
    }
  }
  if ($copy == 1) {
    push (@temp, $_);
  }
  if ( m/<!--\sEnd\sof\sStatcounter\sCode/ ) {
    $copy = 1;
  }
}

@tools_index_file_lines = @temp;

my $print_menu = 0;
my $print_stats_code = 1;

open TOOLS_INDEX, ">$tools_index_file" or die "Can't open $tools_index_file to read: $!\n";
foreach (@tools_index_file_lines) {
  if (( m/<\/body>/ ) && ( $print_stats_code == 1 )){
    foreach (@stats_code) {
      print TOOLS_INDEX $_;
    }
    print TOOLS_INDEX "\n";
  }
  if ( m/<!--\sTop Menu\s-->/ ) {
    $print_menu = 1;
    foreach (@tools_menu) {
      s/res\//..\/res\//;
      if (m/português/) {
        s/.io\/br\//.io\/br\/tools\//g;
      }
      print TOOLS_INDEX $_;
    }
  }
  if ($print_menu == 0) {
    print TOOLS_INDEX $_;
  }
  if ( m/<!--\send\s-->/ ) {
    $print_menu = 0;
  }
  if ( m/<!--\sDefault\sStatcounter\scode/ ) {
    $print_stats_code = 0;
  }
}
close TOOLS_INDEX;


# Update menu, stats code and apps on br home page but keep header, main info and footer

open BR_INDEX, "$br_index_file" or die "Can't open $br_index_file to read: $!\n";
my @br_index_file_lines = <BR_INDEX>;
close BR_INDEX;

open BR_INDEX, ">$br_index_file" or die "Can't open $br_index_file to read: $!\n";

my $print_en = 1;
my $print_br = 0;
my $print_br_menu = 0;
my $print_stats_code = 1;

foreach (@index_file_lines) {

  s/style.css/..\/style.css/g;
  s/src="js\//src="..\/js\//g;
  s/.io\/m/.io\/m\/br/g;
  s/.io\/apps/.io\/br\/apps/g;
  s/Personal\sWebsite/Website Pessoal/g;

  if (( m/<\/body>/ ) && ( $print_stats_code == 1 )) {
    foreach (@stats_code) {
      print BR_INDEX $_;
    }
    print BR_INDEX "\n";
  }

  if ( m/<!--\sTop Menu\s-->/ ) {
    $print_br_menu = 1;
    $print_en = 0;
    $print_br = 0;
    foreach $menu_line (@br_menu) {
      print BR_INDEX $menu_line;
    }
  }

  if ( m/class="home-header"/ ) {
    $print_en = 0;
    foreach $br (@br_index_file_lines) {
      if ( $br =~ m/class="home-header"/ ) {
        $print_br = 1;
      }
      if ($print_br == 1) {
        print BR_INDEX $br;
      }
      if ( $br =~ m/ <\/div>/ ) {
        $print_br = 0;
      }
    }
  }

  if ( m/class="home-main"/ ) {
    $print_en = 0;
    foreach $br (@br_index_file_lines) {
      if ( $br =~ m/class="home-main"/ ) {
        $print_br = 1;
      }
      if ($print_br == 1) {
        print BR_INDEX $br;
      }
      if ( $br =~ m/ <\/div>/ ) {
        $print_br = 0;
      }
    }
  }

  if ( m/class="footer"/ ) {
    $print_en = 0;
    foreach $br (@br_index_file_lines) {
      if ( $br =~ m/class="footer"/ ) {
        $print_br = 1;
      }
      if ($print_br == 1) {
        print BR_INDEX $br;
      }
      if ( $br =~ m/ <\/div>/ ) {
        $print_br = 0;
      }
    }
  }

  if ($print_en == 1) {
    print BR_INDEX $_;
  }

  if ( m/<!--\send\s-->/ ) {
    $print_br_menu = 0;
    $print_en = 1;
  }

  if ($print_br_menu == 0) {
    if ( m/ <\/div>/ ) {
      $print_en = 1;
    }
  }

  if ( m/<!--\sDefault\sStatcounter\scode/ ) {
    $print_stats_code = 0;
  }

}


# Update menu and stats code on br tools page

open BR_TOOLS_INDEX, "$br_tools_index_file" or die "Can't open $br_tools_index_file to read: $!\n";
my @br_tools_index_file_lines = <BR_TOOLS_INDEX>;
close BR_TOOLS_INDEX;

my @temp;
my $copy = 1;
my $stop = 0;

foreach (@br_tools_index_file_lines) {
  if ( m/<!--\sDefault\sStatcounter\scode/ ) {
    $copy = 0;
    while ($stop == 0) {
      $last = pop @temp;
      if ($last =~ /<\/div>/) {
        push @temp, $last;
        push @temp, "\n";
        $stop = 1;
      }
    }
  }
  if ($copy == 1) {
    push (@temp, $_);
  }
  if ( m/<!--\sEnd\sof\sStatcounter\sCode/ ) {
    $copy = 1;
  }
}

@br_tools_index_file_lines = @temp;

my @br_tools_menu = @br_menu;
my $print_menu = 0;
my $print_stats_code = 1;

open BR_TOOLS_INDEX, ">$br_tools_index_file" or die "Can't open $br_tools_index_file to read: $!\n";
foreach (@br_tools_index_file_lines) {
  if (( m/<\/body>/ ) && ( $print_stats_code == 1 )) {
    foreach (@stats_code) {
      print BR_TOOLS_INDEX $_;
    }
    print BR_TOOLS_INDEX "\n";
  }
  if ( m/<!--\sTop Menu\s-->/ ) {
    $print_menu = 1;
    foreach (@br_tools_menu) {
      s/res/..\/res/g;
      if (m/english/) {
        s/.io\//.io\/tools\//g;
      }
      print BR_TOOLS_INDEX $_;
    }
  }
  if ($print_menu == 0) {
    print BR_TOOLS_INDEX $_;
  }
  if ( m/<!--\send\s-->/ ) {
    $print_menu = 0;
  }
  if ( m/<!--\sDefault\sStatcounter\scode/ ) {
    $print_stats_code = 0;
  }

}
close BR_TOOLS_INDEX;


# Create directories structure for apps
if (not -e "apps") {
  system "mkdir apps";
}

chdir "apps";

foreach (@apps_site_dirs) {
  if (not -e $_) {
    system "mkdir $_";
  }
  chdir $_;
  if (not -e "res") {
    system "mkdir res";
  }
  chdir "res";
  if (not -e "img") {
    system "mkdir img";
  }
  chdir "../../"
}

chdir "../";

# Copy english content to br directory
system "cp -r apps br/";
system "cp -r res br/";

chdir "build";


# For each app...

for (my $i = 0; $i < @apps_proj_dirs; $i++) {

  my @menu = @menu;
  my @br_menu = @br_menu;

  # ... copy content from app's repository

  system "cp $projects_path/$apps_proj_dirs[$i]/docs/index.html $pages_root_path/apps/$apps_site_dirs[$i]/";
  system "cp $projects_path/$apps_proj_dirs[$i]/docs/res/img/* $pages_root_path/apps/$apps_site_dirs[$i]/res/img/";
  system "cp $projects_path/$apps_proj_dirs[$i]/docs/br/index.html $pages_root_path/br/apps/$apps_site_dirs[$i]/";
  system "cp $projects_path/$apps_proj_dirs[$i]/docs/br/res/img/* $pages_root_path/br/apps/$apps_site_dirs[$i]/res/img/";
  system "cp $projects_path/$apps_proj_dirs[$i]/app/src/main/ic_launcher-web.png $pages_root_path/res/img/$apps_site_dirs[$i]_icon.png";
  system "cp $projects_path/$apps_proj_dirs[$i]/app/src/main/ic_launcher-web.png $pages_root_path/br/res/img/$apps_site_dirs[$i]_icon.png";

  # ... add menu and stats code to app page

  $app_index_file = "$pages_root_path/apps/".$apps_site_dirs[$i]."/index.html";

  open APP_INDEX, "$app_index_file" or die "Can't open $app_index_file to read: $!\n";
  my @app_index_file_lines = <APP_INDEX>;
  close APP_INDEX;

  open APP_INDEX, ">$app_index_file" or die "Can't open $app_index_file to read: $!\n";
  foreach (@app_index_file_lines) {
    if ( m/<\/body>/ ) {
      foreach (@stats_code) {
        print APP_INDEX $_;
      }
      print APP_INDEX "\n";
    }
    s/style.css/..\/..\/style.css/g;
    print APP_INDEX $_;
    if ( m/<body>/ ) {
      print APP_INDEX "\n";
      foreach (@menu) {
        s/res\/icons\//..\/..\/res\/icons\//g;
        s/res\/img\/logo.png/..\/..\/res\/img\/logo.png/g;
        s/\/br\//\/br\/apps\/$apps_site_dirs[$i]\//g;
        print APP_INDEX $_;
      }
      print APP_INDEX "\n  <div style=\"background-color:#ffffff;margin-top:80px;\">\n";
    }
  }
  close APP_INDEX;

  # ... add menu and stats code to br page

  $app_index_file = "$pages_root_path/br/apps/".$apps_site_dirs[$i]."/index.html";

  open BR_APP_INDEX, "$app_index_file" or die "Can't open $app_index_file to read: $!\n";
  my @app_index_file_lines = <BR_APP_INDEX>;
  close BR_APP_INDEX;

  open BR_APP_INDEX, ">$app_index_file" or die "Can't open $app_index_file to read: $!\n";
  foreach (@app_index_file_lines) {
    if ( m/<\/body>/ ) {
      foreach (@stats_code) {
        print BR_APP_INDEX $_;
      }
      print BR_APP_INDEX "\n";
    }
    s/style.css/..\/..\/style.css/g;
    print BR_APP_INDEX $_;
    if ( m/<body>/ ) {
      print BR_APP_INDEX "\n";
      foreach (@br_menu) {
        s/res\/icons\//..\/..\/res\/icons\//g;
        s/res\/img\/logo.png/..\/..\/res\/img\/logo.png/g;
        if ( m/english/ ) {
          s/.io\//.io\/apps\/$apps_site_dirs[$i]\//g;
        }
        print BR_APP_INDEX $_;
      }
      print BR_APP_INDEX "\n  <div style=\"background-color:#ffffff;margin-top:80px;\">\n";
    }
  }
  close BR_APP_INDEX;

}
