codeunit 50110 "TFB Cust. Fav. Items"
{
    Description = 'Populate Customer Favourite Items';
    SingleInstance = true;
    Subtype = Normal;

    trigger OnRun()
    var
        Customer: Record Customer;

    begin

        Customer.SetLoadFields("No.");
        Customer.SetRange(Blocked, Customer.Blocked::" ");
        If Customer.Findset(false, false) then
            repeat 
                PopulateOneCustomer(Customer."No.");

            until Customer.Next() = 0;


    end;


    var
    procedure PopulateOneCustomer(CustNo: Code[20]): Boolean
    var
        CustSales: Query "TFB Customer Item Sales";

    begin

        CustSales.SetRange(CustNo, CustNo);
        CustSales.Open();
        while CustSales.Read() do
            AddLine(CustNo, CustSales.ItemNo, CustSales.Quantity);

    end;

    local procedure AddLine(CustNo: Code[20]; ItemNo: Code[20]; QtySold: Integer)

    var
        CustFavItem: record "TFB Cust. Fav. Item";

    begin

        If QtySold > 0 then
            If CustFavItem.Get(CustNo, 'DEFAULT', ItemNo) then begin
                If CustFavItem.Source <> CustFavItem.Source::PastBuy then begin
                    CustFavItem.Source := CustFavItem.Source::PastBuy;
                    CustFavItem.Modify();
                end;
            end
            else begin

                CustFavItem.Init();
                CustFavItem."Item No." := ItemNo;
                CustFavItem."Customer No." := CustNo;
                CustFavItem."List No." := 'DEFAULT';
                CustFavItem.Source := CustFavItem.Source::PastBuy;
                CustFavItem.Insert(false);
            end;

    end;
}