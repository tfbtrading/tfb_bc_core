tableextension 50260 "TFB Item" extends Item
{
    fields
    {
        field(50261; "TFB Fumigation"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Fumigation Required?';

        }
        field(50262; "TFB Inspection"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Inspection Required';

        }
        field(50263; "TFB Heat Treatment"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Heat Treatment Required';
        }
        field(50265; "TFB Permit"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Permit Required';

        }

        field(50266; "TFB Est. Storage Duration"; Duration)
        {
            DataClassification = CustomerContent;
            Caption = 'Est. Storage Dur.';
        }

        field(50267; "TFB Default Purch. Code"; Code[20])
        {
            TableRelation = Purchasing;
            ValidateTableRelation = true;
            Caption = 'Default Puch. Code';
        }
        field(50270; "TFB Publishing Block"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Do Not Publish';
        }
        field(50272; "TFB Publish POA Only"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Publish POA Only';

        }
        field(50280; "TFB DropShip Avail."; Option)
        {
            OptionMembers = "Available","Restricted","Out of Stock";
            Caption = 'Dropship Availability';

            trigger OnValidate()

            begin
                If rec."TFB DropShip Avail." = rec."TFB DropShip Avail."::"Out of Stock" then
                    if rec."TFB DropShip ETA" = 0D then
                        FieldError("TFB DropShip ETA", 'Need to indicate next available date if out of stock at vendor');
            end;
        }
        field(50290; "TFB DropShip ETA"; Date)
        {
            Caption = 'Estimated Date Available?';
            trigger OnValidate()

            begin
                If rec."TFB DropShip Avail." = rec."TFB DropShip Avail."::"Out of Stock" then
                    if rec."TFB DropShip ETA" = 0D then
                        FieldError("TFB DropShip ETA", 'Need to indicate next available date if out of stock at vendor');
            end;
        }
        field(50300; "TFB Alt. Names"; Text[255])
        {
            DataClassification = CustomerContent;
            Caption = 'Alternative Names';
        }
        field(50310; "TFB Long Desc."; Text[1024])
        {
            DataClassification = CustomerContent;
            Caption = 'Long Descriptions';

        }

        field(50320; "TFB Out. Qty. On Sales Order"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum("Sales Line"."Outstanding Qty. (Base)" where("Document Type" = const(Order), "Outstanding Qty. (Base)" = filter('>0'), "No." = field("No."), "Drop Shipment" = field("Drop Shipment Filter"), "Location Code" = field("Location Filter")));
            Caption = 'Out. Qty. on Sales Order';

        }

        field(50325; "TFB Qty. In Transit"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum("Item Ledger Entry"."Remaining Quantity" where("Remaining Quantity" = filter('>0'), "Document Type" = const("Transfer Shipment"), "Item No." = field("No."), "Location Code" = field("Location Filter")));
            Caption = 'Qty in Transit';
        }

        field(50326; "TFB Inventory - Excl. Transit"; Decimal)
        {
            CalcFormula = Sum("Item Ledger Entry"."Remaining Quantity" WHERE("Item No." = FIELD("No."),

                                                                  "Location Code" = FIELD("Location Filter"),
                                                                  "Drop Shipment" = FIELD("Drop Shipment Filter"),
                                                                  "Variant Code" = FIELD("Variant Filter"),
                                                                  "Lot No." = FIELD("Lot No. Filter"),
                                                                  "Serial No." = FIELD("Serial No. Filter"),
                                                                  "Unit of Measure Code" = FIELD("Unit of Measure Filter"),
                                                                  "Package No." = FIELD("Package No. Filter"),
                                                                  "Document Type" = filter('<>Transfer Shipment')));
            Caption = 'Inventory - Excl. Transfers';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }

        field(50330; "TFB Unit Price Source"; Code[20])
        {
            Caption = 'Unit Price Source';
            TableRelation = "Customer Price Group";
            ValidateTableRelation = true;
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(50340; "TFB Act As Generic"; Boolean)
        {
            Caption = 'Act as Generic Item';
            DataClassification = CustomerContent;
        }
        field(50345; "TFB Generic Item ID"; Guid)
        {
            Caption = 'Parent Generic Item Guid';
            DataClassification = CustomerContent;
            TableRelation = "TFB Generic Item".SystemId where(Type = const(ItemParent));
            ValidateTableRelation = true;

            trigger OnValidate()

            begin
                If GenericItem.Get("TFB Generic Item ID") then
                    "TFB Parent Generic Item Name" := GenericItem.Description;

            end;
        }
        field(50346; "TFB Parent Generic Item Name"; Text[255])
        {
            Caption = 'Parent Generic Item Name';
            DataClassification = CustomerContent;
            TableRelation = "TFB Generic Item".Description where(Type = const(ItemParent));

            trigger OnValidate()
            begin
                GenericItem.SetRange(Description, Rec."TFB Parent Generic Item Name");
                If GenericItem.FindFirst() then
                    Rec."TFB Generic Item ID" := GenericItem.SystemId;

            end;


        }
        field(50347; "TFB Generic Link Exists"; Boolean)
        {
            Caption = 'Generic Link Exists';
            FieldClass = FlowField;
            CalcFormula = exist("TFB Generic Item" where(SystemId = field("TFB Generic Item ID")));
        }


        field(50350; "TFB External ID"; Text[250])
        {
            Caption = 'External ID';

        }
        field(50360; "TFB Multi-item Pallet Option"; Enum "TFB Multi-item Pallet Option")
        {
            Caption = 'Multi-item Pallet Option';
        }
        field(50365; "TFB No. Of Bags Per Layer"; Integer)
        {
            Caption = 'No. Of Bags Per Layer';
        }
        field(50370; "TFB Vendor is Agent"; Boolean)
        {
            Caption = 'Vendor is Agent';

        }
        field(50380; "TFB Item Manufacturer/Brand"; Code[20])
        {
            Caption = 'Item Manufacturer/Brand';
            TableRelation = Vendor where("TFB Vendor Type" = const(TRADE));
            ValidateTableRelation = true;
        }

    }
    fieldgroups
    {

        addlast(DropDown; Inventory, "Reserved Qty. on Inventory", "Purchasing Code", "Vendor No.")
        {

        }
        addlast(Brick; "Reserved Qty. on Inventory", "Vendor No.") { }


    }

    trigger OnAfterDelete()

    begin
        If Rec."TFB Act As Generic" then
            If GenericItem.GetBySystemId(Rec."TFB Generic Item ID") then
                GenericItem.Delete(false);

    end;

    trigger OnInsert()

    var
        Guid: Guid;

    begin

        If Rec."TFB Act As Generic" then
            If not GenericItem.GetBySystemId(Rec."TFB Generic Item ID") then begin
                Guid := CreateGuid();
                GenericItem.Init();
                GenericItem.SystemId := Guid;
                GenericItem.Description := Rec.Description;
                GenericItem."Item Category Id" := Rec."Item Category Id";
                GenericItem."Item Category Code" := Rec."Item Category Code";

                If Rec.Picture.Count > 0 then
                    GenericItem.Picture.Insert(Rec.Picture.MediaId);
                GenericItem.Type := GenericItem.Type::ItemExtension;
                If GenericItem.Insert(true, true) then begin
                    Rec."TFB Generic Item ID" := GUID;
                    Rec.Modify(false);
                end;
            end;



    end;

    trigger OnModify()

    var
        Guid: Guid;
        Index: Integer;

    begin
        If Rec."TFB Act As Generic" then
            If not GenericItem.GetBySystemId(Rec."TFB Generic Item ID") then begin
                Guid := CreateGuid();
                GenericItem.Init();
                GenericItem.SystemId := Guid;
                GenericItem.Description := Rec.Description;
                GenericItem."Item Category Id" := Rec."Item Category Id";
                GenericItem."Item Category Code" := Rec."Item Category Code";
                If Rec.Picture.Count > 0 then begin
                    Index := 1;
                    GenericItem.Picture.Insert(Rec.Picture.Item(index));
                end;
                GenericItem.Type := GenericItem.Type::ItemExtension;
                If GenericItem.Insert(true, true) then begin
                    Rec."TFB Generic Item ID" := GUID;
                    Rec.Modify(false);
                end;
            end;



        //Removed as this appears to delete any parent item if it was switched from generic to parent
        /*   If Xrec."TFB Act As Generic" and not rec."TFB Act As Generic" then
              If GenericItem.GetBySystemId(xrec."TFB Generic Item ID") then
                  If GenericItem.Type = GenericItem.Type::ItemExtension then begin
                      GenericItem.Delete(false);
                      clear(Guid);
                      Rec."TFB Generic Item ID" := Guid;
                      Rec."TFB Parent Generic Item Name" := '';
                  end
   */


    end;


    trigger OnDelete()

    var
        GenericItemMarketRel: Record "TFB Generic Item Market Rel.";

    begin

        //Ensure removal of corresponding entries in the system
        If Rec."TFB Act As Generic" then
            If GenericItem.GetBySystemId(Rec."TFB Generic Item ID") and (GenericItem.Type = GenericItem.Type::ItemExtension) then begin

                GenericItemMarketRel.SetRange(GenericItemID, Rec.SystemId);
                If GenericItemMarketRel.Count > 0 then
                    GenericItemMarketRel.DeleteAll(false);

                GenericItem.Delete(false);
            end;
    end;


    var
        GenericItem: Record "TFB Generic Item";


}