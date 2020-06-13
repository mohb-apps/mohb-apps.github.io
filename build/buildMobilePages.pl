#!/usr/bin/perl

#
#  File          : buildPages.pl
#  Last modified : 12/06/20 11:49 PM
#
#  Developer     : Haraldo Albergaria Filho, a.k.a. mohb apps
#
#  Description   : Script to create mohb apps mobile website
#  Usage         : buildMobilePages.pl
#
#  --------------------------------------------------------------

my $home_dir            = $ENV{'HOME'};
my $repository_name     = "mohb-apps.github.io";
my $pages_root_path     = $home_dir."/GitHubPages/".$repository_name."/m/";
my $root_index_file     = $pages_root_path."index.html";
my $br_index_file       = $pages_root_path."br/index.html";
my $projects_path       = $home_dir."/AndroidStudioProjects/";

open ROOT_INDEX, "$root_index_file" or die "Can't open $root_index_file to read: $!\n";
my @index_file_lines = <ROOT_INDEX>;
close ROOT_INDEX;

my @apps;
my @apps_proj_dirs;
my @apps_site_dirs;

foreach (@index_file_lines) {
  if ( m/<a\shref=\"https:\/\/mohb-apps\.github\.io\/m\/apps\/.+\/\">(.+)<\/a>\n/ ) {
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

chdir "$pages_root_path";

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

if (not -f $br_index_file) {
  die "There is no br/index.html file! Please, create one and run again.\n";
}

system "cp -r apps br/";
system "cp -r res br/";

my $copy = 0;
my @menu;

foreach (@index_file_lines) {
  if ( m/<!--\sTop Menu\s-->/ ) {
    $copy = 1;
  }
  if ($copy == 1) {
    s/res\//..\/..\/res\//;
    push (@menu, $_);
  }
  if ( m/<!--\send\s-->/ ) {
    $copy = 0;
  }
}

for (my $i = 0; $i < @apps_proj_dirs; $i++) {

  my @menu = @menu;

  system "cp $projects_path/$apps_proj_dirs[$i]/docs/index.html apps/$apps_site_dirs[$i]/";
  system "cp $projects_path/$apps_proj_dirs[$i]/docs/res/img/* apps/$apps_site_dirs[$i]/res/img/";
  system "cp $projects_path/$apps_proj_dirs[$i]/docs/br/index.html br/apps/$apps_site_dirs[$i]/";
  system "cp $projects_path/$apps_proj_dirs[$i]/docs/br/res/img/* br/apps/$apps_site_dirs[$i]/res/img/";

  $app_index_file = "apps/".$apps_site_dirs[$i]."/index.html";

  open APP_INDEX, "$app_index_file" or die "Can't open $app_index_file to read: $!\n";
  my @app_index_file_lines = <APP_INDEX>;
  close APP_INDEX;

  open APP_INDEX, ">$app_index_file" or die "Can't open $app_index_file to read: $!\n";
  foreach (@app_index_file_lines) {
    s/style.css/..\/..\/style.css/g;
    print APP_INDEX $_;
    if ( m/<body>/ ) {
      print APP_INDEX "\n";
      foreach (@menu) {
        s/\/br\//\/br\/apps\/$apps_site_dirs[$i]\//g;
        print APP_INDEX $_;
      }
    }
  }
  close APP_INDEX;

  $app_index_file = "br/apps/".$apps_site_dirs[$i]."/index.html";

  open APP_INDEX_BR, "$app_index_file" or die "Can't open $app_index_file to read: $!\n";
  my @app_index_file_lines = <APP_INDEX_BR>;
  close APP_INDEX_BR;

  open APP_INDEX_BR, ">$app_index_file" or die "Can't open $app_index_file to read: $!\n";
  foreach (@app_index_file_lines) {
    s/style.css/..\/..\/style.css/g;
    print APP_INDEX_BR $_;
    if ( m/<body>/ ) {
      print APP_INDEX_BR "\n";
      foreach (@menu) {
        s/contact/contato/g;
        s/.io\/m\//.io\/m\/br\//g;
        s/br\/br\///g;
        s/portuguese.png/english.png/g;
        s/alt="português"/alt="english"/g;
        print APP_INDEX_BR $_;
      }
    }
  }
  close APP_INDEX_BR;

}

$br_index_orig_file = $pages_root_path."br/index.html";

open INDEX_BR, "$br_index_file" or die "Can't open $br_index_file to read: $!\n";
my @br_index_file_lines = <INDEX_BR>;
close INDEX_BR;

open INDEX_BR, ">$br_index_file" or die "Can't open $br_index_file to read: $!\n";

my $print_en = 1;
my $print_br = 0;

foreach $en (@index_file_lines) {
  if ( $en =~ m/class="home-header"/ ) {
    $print_en = 0;
    foreach $br (@br_index_file_lines) {
      if ( $br =~ m/class="home-header"/ ) {
        $print_br = 1;
      }
      if ($print_br == 1) {
        print INDEX_BR $br;
      }
      if ( $br =~ m/ <\/div>/ ) {
        $print_br = 0;
      }
    }
  }
  if ( $en =~ m/class="home-main"/ ) {
    $print_en = 0;
    foreach $br (@br_index_file_lines) {
      if ( $br =~ m/class="home-main"/ ) {
        $print_br = 1;
      }
      if ($print_br == 1) {
        print INDEX_BR $br;
      }
      if ( $br =~ m/ <\/div>/ ) {
        $print_br = 0;
      }
    }
  }
  if ( $en =~ m/class="footer"/ ) {
    $print_en = 0;
    foreach $br (@br_index_file_lines) {
      if ( $br =~ m/class="footer"/ ) {
        $print_br = 1;
      }
      if ($print_br == 1) {
        print INDEX_BR $br;
      }
      if ( $br =~ m/ <\/div>/ ) {
        $print_br = 0;
      }
    }
  }
  if ($print_en == 1) {
    print INDEX_BR $en;
  }
  if ( $en =~ m/ <\/div>/ ) {
    $print_en = 1;
  }

}

open INDEX_BR, "$br_index_file" or die "Can't open $br_index_file to read: $!\n";
my @br_index_file_lines = <INDEX_BR>;
close INDEX_BR;

open INDEX_BR, ">$br_index_file" or die "Can't open $br_index_file to read: $!\n";

foreach (@br_index_file_lines) {
  s/style.css/..\/style.css/g;
  s/..\/..\/res/res/g;
  s/contact/contato/g;
  s/.io\/m\//.io\/m\/br\//g;
  s/br\/br\///g;
  s/.io\/"><img class="desktop"/.io\/br\/"><img class="desktop"/g;
  s/portuguese.png/english.png/g;
  s/alt="português"/alt="english"/g;
  print INDEX_BR $_;
}
close INDEX_BR;
