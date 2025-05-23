table 50000 "PTE Auction Info"
{
    Caption = 'Auction Info';
    DataClassification = CustomerContent;
    LookupPageId = "PTE Auction Info List";
    DrillDownPageId = "PTE Auction Info List";

    fields
    {
        field(1; "Auction No."; Code[20])
        {
            Caption = 'Auction No.';
        }
        field(5; "Internal Note"; Text[100])
        {
            Caption = 'Internal Note';
        }
        field(10; "Negotiation No."; Code[20])
        {
            Caption = 'Negotiation No.';
        }
        field(15; "Contact Info"; Text[100])
        {
            Caption = 'Contact Info';
        }
        field(20; "Auction Url"; Text[250])
        {
            Caption = 'Auction Url';
            ExtendedDatatype = Url;
        }
    }
    keys
    {
        key(PK; "Auction No.")
        {
            Clustered = true;
        }
    }
}
