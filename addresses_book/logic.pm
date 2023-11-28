package Logic;

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(create_database, load_contacts);

my ($script_dir) = $0 =~ /^(.*)[\/\\]/;
my $file_path = $script_dir . "/data.txt";

sub create_database {
    if (! -e $file_path) {
        open my $file_handle, '>', $file_path or die "Błąd: Nie można stworzyć pliku $file_path.";
        close $file_handle;
    }
}

sub load_contacts {
    my @contacts;

    open(my $data, '<', $file_path) or die "Błąd: Nie udało się otworzyć pliku $file_path."; 
    while (my $line = <$data>) { 
        chomp $line; 
        my ($name, $phone, $email) = split(/\|/, $line);   
        push @contacts, {
                name    => $name,
                phone   => $phone,
                email   => $email,
        };
    }
    close $data;

    return sort { $a->{name} cmp $b->{name} } @contacts;
}