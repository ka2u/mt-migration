package MT::Migration;

use strict;
use warnings;
use File::Spec::Functions;
use IO::Uncompress::Unzip qw(unzip $UnzipError);
use Archive::Tar;
use File::Copy;

my $static = "mt-static";
my $blog = "blog";
my $mt   = "mt";

sub migrate {
    my $class = shift;
    my ($base_path, $old_mt, $new_mt, $backup_dir, $user, $password, $database) = @_;

    $class->backup(catdir($base_path, $old_mt), $backup_dir, $user, $password, $database);

    move catdir($base_path, $old_mt), catdir($base_path, "mt_old");
    #my $status = unzip catdir($base_path, $new_mt) => catdir($base_path, "mt5") or
    #    die "unzip failed: $UnzipError";
    my $new_dir = catdir($base_path, "mt");
    mkdir $new_dir or die "can't make dir: $new_dir";
    my $tar = Archive::Tar->new(catdir($base_path, $new_mt));
    $tar->setcwd($new_dir);
    $tar->extract;
    # TODO
    my($dir, $version, $extension) = split '\.', $new_mt;
    warn catdir($new_dir, $dir.".".$version) .":". catdir($new_dir, "mt");
    move catdir($new_dir, $dir.".".$version), catdir($new_dir, "mt");

}

sub backup {
    my $class = shift;
    my ($base_path, $backup_dir, $user, $password, $database) = @_;

    mkdir $backup_dir or die "can't make dir: $backup_dir";
    $class->cp(catdir($base_path, $static), $backup_dir);
    $class->cp(catdir($base_path, $mt), $backup_dir);
    $class->cp(catdir($base_path, $blog), $backup_dir);

    $class->mysqldump($backup_dir, $user, $password, $database);
} 

sub cp {
    my $class = shift;
    my ($from, $to) = @_;
    system("cp -Rp $from $to") == 0
        or die "external cp command status was $?";
}

sub mysqldump {
    my $class = shift;
    my ($backup_dir, $user, $password, $database) = @_;

    system("mysqldump -a --skip-lock-tables --user=$user --password=$password $database > " .
        catdir($backup_dir, "backup.mysql")) == 0
            or die "mysqldump failed: $?";
}

1;
