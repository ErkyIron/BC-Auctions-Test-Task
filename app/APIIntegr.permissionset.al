permissionset 50000 "PTE API Integr."
{
    Caption = 'API Integration', Locked = true;
    Assignable = true;
    Permissions = tabledata "PTE Auction Info" = RIMD,
        table "PTE Auction Info" = X,
        codeunit "PTE API Integration Mgt." = X,
        page "PTE Auction Info List" = X,
        codeunit "PTE Auction Info Background" = X,
        codeunit "PTE Install Helpers" = X;
}