table 50116 "TFB Sample Request Line"
{
    DataClassification = CustomerContent;


    fields
    {
        field(3; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            TableRelation = "TFB Sample Request";
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }

        field(6; "No."; Code[20])
        {

            Caption = 'Item No.';
            TableRelation = Item;
            ValidateTableRelation = true;

            trigger OnValidate()
            var

            begin
                GetSalesSetup();
                GetSalesHeader();

            end;
        }

        field(10; "Sourced From"; enum "TFB Sample Request Line Source")
        {
            Caption = 'Sourced From';

        }
        field(15; "Location"; Code[20])
        {
            TableRelation = Location;
            ValidateTableRelation = true;

            trigger OnValidate()

            var

            begin
                If not ("Sourced From" = "Sourced From"::Warehouse) and (Location <> '') then
                    FieldError(Location, NotValidLocationMsg);
            end;
        }

        field(20; "Sample Size SystemID"; Guid)
        {
            TableRelation = "TFB Sample Request Size".SystemId;
        }

        field(30; "Line Status"; Enum "TFB Sample Request Status")
        {

        }

        field(11; Description; Text[100])
        {
            Caption = 'Description';
            TableRelation = Item.Description WHERE(Blocked = CONST(false), "Sales Blocked" = CONST(false));
            ValidateTableRelation = false;


            trigger OnValidate()
            var
                Item: Record Item;
                DescriptionIsNo: Boolean;

            begin

                if "No." <> '' then
                    exit;

                if StrLen(Description) <= MaxStrLen(Item."No.") then
                    DescriptionIsNo := Item.Get(Description)
                else
                    DescriptionIsNo := false;

                if not DescriptionIsNo then begin

                    Item.SetRange(Description, Description);
                    if Item.FindFirst() then begin
                        Validate("No.", Item."No.");
                        exit;
                    end;

                    // looking for an item with similar description
                    Item.SetFilter(Description, '''@' + ConvertStr(Description, '''', '?') + '''');
                    if Item.FindFirst() then begin
                        Validate("No.", Item."No.");
                        exit;
                    end;
                end;

            end;

        }


    }

    keys
    {
        key(PK; "Document No.", "Line No.")
        {
            Clustered = true;
        }
    }

    var
        SalesHeader: Record "Sales Header";
        SampleSize: Record "TFB Sample Request Size";

        NotValidLocationMsg: Label 'Location is not valid unless sourced from warehouse';

    procedure GetSalesHeader() SampleRequest: Record "TFB Sample Request";
    begin
        SampleRequest.Get(Rec."Document No.");
        Exit(SampleRequest);
    end;

    procedure GetItem() Item: Record Item;
    begin
        Item.Get("No.");

    end;

    local procedure CopyFromItem()
    var
        Item: Record Item;
        PrepaymentMgt: Codeunit "Prepayment Mgt.";
        IsHandled: Boolean;
    begin
        Item := GetItem;

        Description := Item.Description;

    end;

    protected procedure GetItemBaseUnitOfMeasure(): Record "Item Unit of Measure"

    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";

    begin

        ItemUnitOfMeasure.SetRange("Item No.", Rec."No.");
        ItemUnitOfMeasure.SetRange(Code, GetItem."Base Unit of Measure");
        ItemUnitOfMeasure.FindFirst();
        Exit(ItemUnitOfMeasure);

    end;

    local procedure GetSalesSetup() SalesSetup: Record "Sales & Receivables Setup";
    begin

        SalesSetup.Get();
        Exit(SalesSetup);

    end;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}