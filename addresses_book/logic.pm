package Logic;

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(create_database, load_contacts, save_contacts, add_contact, remove_contact, listOne);
use utf8;
use open qw(:std :utf8);

my ($script_dir) = $0 =~ /^(.*)[\/\\]/;
my $file_path = $script_dir . "/data.txt";

sub create_database {
    my $file_name = @_[0];

    if ($file_name) {
        $file_path = $script_dir . "/" . $file_name;
    }

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
        my ($name, $description, $phone, $email) = split(/\|/, $line);   
        push @contacts, {
                name            => $name,
                description     => $description,
                phone           => $phone,
                email           => $email,
        };
    }
    close $data;

    return sort { lc($a->{name}) cmp lc($b->{name}) } @contacts;
}

sub save_contacts {
    my @contacts = @_;
    @contacts = sort { lc($a->{name}) cmp lc($b->{name}) } @contacts;

    open(my $file, '>', $file_path) or die "Błąd: Nie udało się otworzyć pliku $file_path."; 
    for my $contact (@contacts) {
        print $file "$contact->{name}|$contact->{description}|$contact->{phone}|$contact->{email}\n";
    }
    close $file;
}

sub add_contact {
    my $contact_info = @_[0];
    my @contact_infos = split(/\|/, $contact_info); 
    my @new_contacts;

    my $name = '';
    my $description = '';
    my $phone = '';
    my $email = '';
    
    for my $i (0 .. $#contact_infos) {
        if ($i % 4 == 0) {
            $name = $contact_infos[$i];
        }
        if ($i % 4 == 1) {
            $description = $contact_infos[$i];
        }
        if ($i % 4 == 2) {
            $phone = $contact_infos[$i];
            $phone =~ s/^\s+|\s+$//g;
        }
        if ($i % 4 == 3) {
            $email = $contact_infos[$i];

            if ($name ne '' || $phone ne '' || $email ne '') {
                validate_contact_data($name, $phone, $email);
                push @new_contacts, {
                    name            => $name,
                    description     => $description,
                    phone           => $phone,
                    email           => $email,
                };
                $name = '';
                $description = '';
                $phone = '';
                $email = '';
            }
        }
    }
    if ($name ne '' || $phone ne '' || $email ne '') {
        validate_contact_data($name, $phone, $email);
        push @new_contacts, {
            name            => $name,
            description     => $description,
            phone           => $phone,
            email           => $email,
        };
    }

    @saved_contacts = load_contacts();

    foreach my $new_contact (@new_contacts) {
        my $name_exists = grep { $_->{name} eq $new_contact->{name} } @saved_contacts;
        if ($name_exists) {
            print "Błąd: Kontakt o nazwie '$new_contact->{name}' już istnieje.\n";
            exit 1;
        } else {
            push @saved_contacts, $new_contact;
        }
    }

    save_contacts(@saved_contacts);
}

sub remove_contact {
    my $contact_name = $_[0];
    my @saved_contacts = load_contacts();

    my $contact_found = 0;

    for my $contact (@saved_contacts) {
        if ($contact->{name} eq $contact_name) {
            $contact_found = 1;
            last;
        }
    }

    if ($contact_found) {
        @saved_contacts = grep { $_->{name} ne $contact_name } @saved_contacts;
        save_contacts(@saved_contacts);
    } else {
        print "Błąd: Kontakt '$contact_name' nie został znaleziony.\n";
    }
}

sub listAll {
    my $max_contacts = $_[0];
    my @saved_contacts = load_contacts();

    if ($max_contacts ne "" && $max_contacts < @saved_contacts) {
        if ($max_contacts =~ /^\d+$/ && $max_contacts > 0) {
            @saved_contacts = @saved_contacts[0 .. $max_contacts - 1];
        } else {
            print "Błąd: Podana liczba kontaktów musi być liczbą większą od zera.\n";
            exit 1;
        }
    }

    if (@saved_contacts) {
        print "+--------------------------------+----------------------------------------------------+--------------+--------------------------------+\n";
        printf "| %-30s | %-50s | %-12s | %-30s |\n", 'Nazwa', 'Opis', 'Telefon', 'Email';
        print "+--------------------------------+----------------------------------------------------+--------------+--------------------------------+\n";

        for my $contact (@saved_contacts) {
            printf "| %-30s | %-50s | %-12s | %-30s |\n", $contact->{name}, $contact->{description}, $contact->{phone}, $contact->{email};
        }

        print "+--------------------------------+----------------------------------------------------+--------------+--------------------------------+\n";
    } else {
        print "Nie znaleziono kontaktów.\n";
    }
}

sub listOne {
    my $contact_name = $_[0];
    my @saved_contacts = load_contacts();

    my $contact_found = 0;

    for my $contact (@saved_contacts) {
        if ($contact->{name} eq $contact_name) {
            print "Nazwa: $contact->{name}\n";
            print "Opis: $contact->{description}\n" if $contact->{description};
            print "Telefon: $contact->{phone}\n" if $contact->{phone};
            print "Email: $contact->{email}\n" if $contact->{email};
            $contact_found = 1;
            last;
        }
    }

    if (! $contact_found) {
        print "Błąd: Kontakt '$contact_name' nie został znaleziony.\n";
    }
}

sub validate_contact_data {
    if (@_[0] eq '') {
        print "Błąd: Nazwa kontaktu jest wymagana.\n";
        exit 1;
    } else {
        if (!(@_[0] =~ /^\S+$/)) {
            print "Błąd: Nazwa kontaktu nie jest jednoczłonowa.\n";
            exit 1;
        }
    }
    if (@_[1] eq '' && @_[2] eq '') {
        print "Błąd: Wymagane jest podanie minimum jednej formy kontaktu (telefon, email).\n";
        exit 1;
    }
    if (@_[1] ne '') {  
        my $phone_number = $_[1];
        $phone_number =~ s/\s//g;

        if ($phone_number !~ /^\d{9}$/) {
            print "Błąd: Nieprawidłowy numer telefonu. Numer powinien składać się z 9 cyfr, z opcjonalnymi spacjami między nimi.\n";
            exit 1;
        }
    }
    if (@_[2] ne '') {
        if ($_[2] !~ /^[^\s@]+@[^\s@]+\.[^\s@]+$/) {
            print "Błąd: Nieprawidłowy adres email.\n";
            exit 1;
        }
    }
}
