table 50181 "TFB Container Entry"
{
    DataClassification = CustomerContent;
    Caption = 'Inbound Shipment';
    LookupPageId = "TFB Container Entry List";
    DataCaptionFields = "No.", "Vendor Name", "Container No.";


    fields
    {
        field(10; "No."; Code[20])
        {
            DataClassification = CustomerContent;


            trigger OnValidate()

            BEGIN
                IF "No." <> xRec."No." THEN BEGIN
                    PurchaseSetup.GET();
                    NoSeriesMgt.TestManual(PurchaseSetup."TFB Container Entry Nos.");
                    "No. Series" := '';

                END;
            end;


        }
        field(20; "No. Series"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
            ValidateTableRelation = true;

        }
        field(30; "Vendor No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Vendor;
            ValidateTableRelation = true;

            trigger OnValidate()
            var
                VendorRec: Record Vendor;
            begin
                VendorRec.Get("Vendor No.");
                "Vendor Name" := VendorRec.Name;
                "Order Reference" := '';
                "Landed Cost Template" := VendorRec."TFB Landed Cost Profile";
                "Ship Via" := VendorRec."TFB Ship Via Default";
                "Shipping Line" := VendorRec."Shipping Agent Code";


            end;


        }
        field(40; "Vendor Name"; Text[100])
        {
            Caption = 'Vendor Name';
            DataClassification = CustomerContent;
            TableRelation = Vendor;
            ValidateTableRelation = False;

            trigger OnValidate()

            var
                VendorRec: Record Vendor;
            begin

                Validate("Vendor No.", VendorRec.GetVendorNo("Vendor Name"));


            end;

        }
        field(50; "Alt. Consignee"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Customer;
            ValidateTableRelation = true;
        }
        field(55; "Alt. Consignee Name"; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup(Customer.Name where("No." = field("Alt. Consignee")));
        }

        field(60; "Shipping Line"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Shipping Agent".Code;
            ValidateTableRelation = true;
        }
        field(65; "Vessel Details"; Text[100])
        {
            DataClassification = CustomerContent;

        }
        field(70; "Ship Via"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "TFB Container Route";
            ValidateTableRelation = true;

        }
        field(80; "Booking Reference"; Text[20]) { DataClassification = CustomerContent; }
        field(90; "Status"; Enum "TFB Container Status")
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            var

                Msg: Label 'Do you want to update corresponding date with todays date?';

            begin

                //Check if it should be closed

                case Status of
                    Status::Closed:
                        Closed := true;
                    Status::Cancelled:
                        Closed := true;
                    else
                        Closed := false;
                end;

                if Confirm(Msg) then
                    case Status of
                        Status::ShippedFromPort:
                            "Departure Date" := Today();
                        Status::PendingFumigation:
                            "Arrival Date" := Today();
                        Status::Closed:
                            "Warehouse Date" := Today();
                    end;
            end;
        }
        field(92; "Closed"; Boolean)
        {
            InitValue = False;
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(100; "Type"; Enum "TFB Container Entry Type")
        {
            DataClassification = CustomerContent;

            Trigger OnValidate()

            begin
                If Rec.Type <> xRec.Type then
                    Validate("Order Reference", '');

            end;

        }
        field(110; "Origin Reference"; Code[20])
        {
            DataClassification = CustomerContent;

        }
        field(120; "Broker Contact"; Code[20])
        {
            TableRelation = Contact;
            ValidateTableRelation = true;
            DataClassification = CustomerContent;

        }
        field(130; "Order Reference"; Code[20])
        {
            DataClassification = CustomerContent;


            trigger OnLookup()

            var
                LookupReference: Code[20];

            begin

                LookupReference := LookupOrderReference();
                validate("Order Reference", LookupReference);
            end;


            trigger OnValidate()

            var

            begin

                //Firest check if order reference is a duplicate

                //New order reference has been specified
                if ("Order Reference" <> '') and (xRec."Order Reference" = '') then
                    case Type of

                        type::PurchaseOrder:
                            UpdateNewPurchaseOrderLink("Order Reference");
                    end
                else
                    //Order reference field has been cleared for some reason
                    if ("Order Reference" = '') and (xRec."Order Reference" <> '') then
                        case Type of

                            type::PurchaseOrder:
                                ClearPurchaseOrderLink(xrec."Order Reference");
                        end
                    else
                        //If order reference has been changed - clear purchase order lines
                        if (rec."Order Reference" <> xrec."Order Reference") then
                            case Type of

                                type::PurchaseOrder:
                                    ChangePurchaseOrderLink(rec."Order Reference", xrec."Order Reference");
                            end;
            end;

        }
        field(132; "Vendor Reference"; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Purchase Header"."Vendor Order No." where("No." = field("Order Reference")));

        }

        field(140; "Order Type"; Code[20])
        {
            DataClassification = CustomerContent;
        }

        field(150; "Landed Cost Template"; Code[20])
        {
            TableRelation = "TFB Landed Cost Profile";
            ValidateTableRelation = true;
            DataClassification = CustomerContent;
        }
        field(160; "Container No."; Text[20]) { DataClassification = CustomerContent; }
        field(170; "Bill of Lading"; Text[20]) { DataClassification = CustomerContent; }

        field(180; "Est. Departure Date"; Date)
        {

            DataClassification = CustomerContent;
            trigger OnValidate()

            begin
                If "Est. Departure Date" < Today() then
                    If Dialog.Confirm('Est. Departure Date of %1 is before today. Are you sure?', false, "Est. Departure Date") then
                        RecalculateDates()
                    else
                        "Est. Departure Date" := xrec."Est. Departure Date";

            end;


        }
        field(190; "Est. Arrival Date"; Date)
        {
            DataClassification = CustomerContent;

            trigger OnValidate()

            begin
                If "Est. Arrival Date" < Today() then
                    If Dialog.Confirm('Est. Arrival Date of %1 is before today. Are you sure?', false, "Est. Arrival Date") then
                        RecalculateDates("Est. Arrival Date")
                    else
                        "Est. Arrival Date" := xrec."Est. Arrival Date";
            end;
        }
        field(200; "Est. Clear Date"; Date) { DataClassification = CustomerContent; Caption = 'Est. Avail. At Wharf'; }
        field(210; "Est. Warehouse"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Est. Avail. To Sell';
            trigger OnValidate()

            begin
                If "Est. Warehouse" < Today() then
                    If not Dialog.Confirm('Est. Availability Date of %1 is before today. Are you sure?', false, "Est. Warehouse") then
                        "Est. Warehouse" := xrec."Est. Warehouse";

            end;
        }
        field(212; "Est. Return Cutoff"; Date) { DataClassification = CustomerContent; }

        field(220; "Departure Date"; Date) { DataClassification = CustomerContent; }
        field(230; "Arrival Date"; Date) { DataClassification = CustomerContent; }

        field(234; "Fumigation Date"; Date) { DataClassification = CustomerContent; Caption = 'Fumigation Commenced'; }
        field(235; "Fumigation Release Date"; Date) { DataClassification = CustomerContent; Caption = 'Released from Fumigation'; }
        field(236; "Inspection Date"; Date) { DataClassification = CustomerContent; Caption = 'Inspection Booked On'; }
        field(238; "Heat Treatment Date"; Date) { DataClassification = CustomerContent; Caption = 'Heat Treatment Booked On'; }
        field(240; "Clear Date"; Date) { DataClassification = CustomerContent; Caption = 'Available at Wharf'; }
        field(250; "Warehouse Date"; Date) { DataClassification = CustomerContent; Caption = 'Available to Sell'; }
        field(252; "Container Returned"; Date) { DataClassification = CustomerContent; }


        field(260; "Fumigation Req."; Boolean)
        {
            DataClassification = CustomerContent;
            trigger OnValidate()

            begin
                RecalculateDates();
            end;
        }
        field(270; "Inspection Req."; Boolean)
        {
            DataClassification = CustomerContent;

            trigger OnValidate()

            begin
                RecalculateDates();
            end;
        }
        field(280; "IFIP Req."; Boolean) { DataClassification = CustomerContent; }

        field(282; "Heat Treat. Req."; Boolean)
        {

            DataClassification = CustomerContent;

            trigger OnValidate()

            begin
                RecalculateDates();
            end;

        }


        field(285; "Purchase Receipt No."; Code[20])
        {
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Replaced with flowfield';
        }
        field(290; "Transfer Order No."; Code[20])
        {
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Replaced with flowfield';
        }
        field(300; "Transfer Receipt No."; Code[20])
        {
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Replaced with flowfield';
        }
        field(310; "Transfer Shipment No."; Code[20])
        {
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Replaced with flowfield';
        }
        field(320; "Quarantine Reference"; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(400; "Qty. On Purch. Rcpt"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Purch. Rcpt. Line"."Quantity (Base)" where("Order No." = field("Order Reference")));
        }
        field(410; "Qty. On Transfer Order"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Transfer line"."Quantity (Base)" where("TFB Container Entry No." = field("No."), "Qty. to Ship (Base)" = filter('>0'), "Quantity Shipped" = filter('>0')));
        }
        field(415; "No. Of Transfer Orders"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Transfer Receipt Header" where("TFB Container Entry No." = field("No.")));
        }
        field(420; "Qty. On Transfer Rcpt"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Transfer Receipt Line"."Quantity (Base)" where("TFB Container Entry No." = field("No.")));
        }
        field(425; "No. of Transfer Receipts"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Transfer Receipt Header" where("TFB Container Entry No." = field("No.")));
        }

        field(430; "Qty. On Transfer Ship."; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Transfer Shipment Line"."Quantity (Base)" where("TFB Container Entry No." = field("No.")));
        }
        field(435; "No. Of Transfer Shipments"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Transfer Shipment Header" where("TFB Container Entry No." = field("No.")));
        }
        field(500; "Unpack Worksheet Attach."; BigInteger)
        {
            DataClassification = CustomerContent;
            Editable = false;

        }

    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
        key(Container; "Container No.")
        {

        }
        key(ETA; "Est. Arrival Date")
        {


        }
        key(ETD; "Est. Departure Date")
        {

        }
        key(ETW; "Est. Warehouse")
        {

        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "No.", "Container No.", Status, "Vendor Name", "Est. Departure Date", "Est. Arrival Date", "Departure Date", "Arrival Date")
        {

        }
        fieldgroup(Brick; "No.", "Container No.", "Vendor No.", "Est. Departure Date", "Est. Arrival Date")
        {

        }

    }

    var


        PurchaseSetup: Record "Purchases & Payables Setup";


        NoSeriesMgt: Codeunit NoSeriesManagement;

    trigger OnInsert()
    begin

        If "No." = '' then begin

            PurchaseSetup.Get();
            PurchaseSetup.TestField("TFB Container Entry Nos.");
            NoSeriesMgt.InitSeries(PurchaseSetup."TFB Container Entry Nos.", xRec."No. Series", 0D, "No.", "No. Series");
        end;
    end;



    local procedure RecalculateDates(): Boolean

    var

        recRoute: record "TFB Container Route";
        lcProfile: record "TFB Landed Cost Profile";
        location: record Location;
        testDF: DateFormula;
        estArrival: DateTime;
        estAvailToPickup: DateTime;
        estAvailAtWarehouse: DateTime;
        totaldelay: Duration;

    begin

        if "Est. Departure Date" <> 0D then
            if recRoute.get("Ship Via") then begin
                estArrival := CreateDateTime("Est. Departure Date", Time()) + recRoute."Days to Port";

                estAvailToPickup := estArrival + recRoute."Days to Clear";

                if location.get(recRoute."Ship To") then begin

                    if "Fumigation Req." then
                        totaldelay := totaldelay + location."TFB Fumigation Time Delay";

                    if ("Inspection Req.") or ("IFIP Req.") then
                        totaldelay := totaldelay + location."TFB Inspection Time Delay";

                    if ("Heat Treat. Req.") then
                        totaldelay := totaldelay + location."TFB Heat Treat. Time Delay";
                end;

                if lcProfile.get("Landed Cost Template") then
                    If not (lcProfile."Demurrage Days" = testDF) then
                        "Est. Return Cutoff" := CalcDate(lcProfile."Demurrage Days", DT2Date(estAvailToPickup));


                estAvailAtWarehouse := estAvailToPickup + totaldelay;


                "Est. Arrival Date" := DT2Date(estArrival); //Calculate date to arrival at port
                "Est. Clear Date" := DT2Date(estAvailToPickup); //Calculate date to when its available for pickup
                "Est. Warehouse" := CalcDate(location."Inbound Whse. Handling Time", DT2Date(estAvailAtWarehouse)); //Calculate date for transhipment

            end;

    end;

    local procedure RecalculateDates(EstArrivalDate: Date): Boolean

    var

        recRoute: record "TFB Container Route";
        lcProfile: record "TFB Landed Cost Profile";
        location: record Location;
        testDF: DateFormula;
        estArrival: DateTime;
        estAvailToPickup: DateTime;
        estAvailAtWarehouse: DateTime;
        totaldelay: Duration;

    begin

        if "Est. Departure Date" <> 0D then
            if recRoute.get("Ship Via") then
                if EstArrivalDate > 0D then begin
                    estArrival := CreateDateTime(EstArrivalDate, Time());

                    estAvailToPickup := estArrival + recRoute."Days to Clear";

                    if location.get(recRoute."Ship To") then begin

                        if "Fumigation Req." then
                            totaldelay := totaldelay + location."TFB Fumigation Time Delay";

                        if ("Inspection Req.") or ("IFIP Req.") then
                            totaldelay := totaldelay + location."TFB Inspection Time Delay";
                    end;

                    if lcProfile.get("Landed Cost Template") then
                        If not (lcProfile."Demurrage Days" = testDF) then
                            "Est. Return Cutoff" := CalcDate(lcProfile."Demurrage Days", DT2Date(estAvailToPickup));


                    estAvailAtWarehouse := estAvailToPickup + totaldelay;


                    "Est. Arrival Date" := DT2Date(estArrival); //Calculate date to arrival at port
                    "Est. Clear Date" := DT2Date(estAvailToPickup); //Calculate date to when its available for pickup
                    "Est. Warehouse" := CalcDate(location."Inbound Whse. Handling Time", DT2Date(estAvailAtWarehouse)); //Calculate date for transhipment

                end;
    end;






    local procedure UpdateNewPurchaseOrderLink(OrderReference: Code[20]): Boolean

    var
        PurchaseLine: Record "Purchase Line";
        ContainerEntry: Record "TFB Container Entry";
        Item: Record Item;
        InspectionReq: Boolean;
        FumigationReq: Boolean;

    begin
        //Assume default for inspection parameters

        InspectionReq := false;
        FumigationReq := false;

        //Check for duplicate
        ContainerEntry.Reset();
        ContainerEntry.SetRange("Order Type", "Order Type");
        ContainerEntry.SetRange("Order Reference", OrderReference);
        If not ContainerEntry.Isempty() then begin
            FieldError("Order Reference", 'Purchase Order Already has a Container Specified as' + ContainerEntry."Container No.");
            Exit(false);
        end;


        //Get Purchase Lines related to order reference
        PurchaseLine.SetRange("Document No.", OrderReference);
        PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
        If PurchaseLine.FindSet(true, false) then
            repeat

                //Set correct reference to TFB container entry no.
                PurchaseLine."TFB Container Entry No." := "No.";
                PurchaseLine."TFB Container No." := "Container No.";
                PurchaseLine.Modify();

                //Check if any item on line requires special treament and flag on container
                Item.Reset();
                If Item.Get(PurchaseLine."No.") then begin
                    If Item."TFB Fumigation" = true then FumigationReq := true;
                    If Item."TFB Inspection" = true then InspectionReq := true;
                end;

            until PurchaseLine.Next() = 0;

        Rec."Inspection Req." := InspectionReq;
        Rec."Fumigation Req." := FumigationReq;

    end;

    local procedure ChangePurchaseOrderLink(NewOrderReference: Code[20]; OldOrderReference: Code[20]): Boolean

    var
        PurchaseLine: Record "Purchase Line";
        ContainerEntry: Record "TFB Container Entry";
        Item: Record Item;
        InspectionReq: Boolean;
        FumigationReq: Boolean;

    begin
        //Assume default for inspection parameters

        InspectionReq := false;
        FumigationReq := false;

        //Check for duplicate
        ContainerEntry.Reset();
        ContainerEntry.SetRange("Order Type", "Order Type");
        ContainerEntry.SetRange("Order Reference", NewOrderReference);
        If not ContainerEntry.IsEmpty() then begin
            FieldError("Order Reference", 'Purchase Order Already has a Container Specified as' + ContainerEntry."Container No.");
            Exit(false);
        end;


        //Get Purchase Lines related to order reference
        PurchaseLine.SetRange("Document No.", NewOrderReference);
        PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
        If PurchaseLine.FindSet(true, false) then
            repeat

                //Set correct reference to TFB container entry no.
                PurchaseLine."TFB Container Entry No." := "No.";
                PurchaseLine.Modify();

                //Check if any item on line requires special treament and flag on container
                Item.Reset();
                If Item.Get(PurchaseLine."No.") then begin
                    If Item."TFB Fumigation" = true then FumigationReq := true;
                    If Item."TFB Inspection" = true then InspectionReq := true;
                end;

            until PurchaseLine.Next() = 0;

        Rec."Inspection Req." := InspectionReq;
        Rec."Fumigation Req." := FumigationReq;

        //Clear records from old purchase order lines
        PurchaseLine.Reset();
        PurchaseLine.SetRange("Document No.", OldOrderReference);
        PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
        If PurchaseLine.FindSet(true, false) then
            repeat

                //Set correct reference to TFB container entry no.
                PurchaseLine."TFB Container Entry No." := '';
                PurchaseLine.Modify();

            //Check if any item on line requires special treament and flag on container

            until PurchaseLine.Next() = 0;

    end;

    local procedure ClearPurchaseOrderLink(OrderReference: Code[20]): Boolean

    var
        PurchaseLine: Record "Purchase Line";

    begin
        //Assume default for inspection parameters

        //Get Purchase Lines related to order reference
        PurchaseLine.SetRange("Document No.", OrderReference);
        PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
        If PurchaseLine.FindSet(true, false) then
            repeat

                //Set correct reference to TFB container entry no.
                PurchaseLine."TFB Container Entry No." := '';
                PurchaseLine.Modify();

            until PurchaseLine.Next() = 0;

        //Reset to default
        Rec."Inspection Req." := false;
        Rec."Fumigation Req." := false;

    end;

    local procedure LookupOrderReference(): Code[20]

    var
        PurchaseOrders: record "Purchase Header";


    begin

        case Type of
            Type::PurchaseOrder:
                begin
                    PurchaseOrders.Reset();
                    PurchaseOrders.SetRange("Document Type", PurchaseOrders."Document Type"::Order);
                    PurchaseOrders.SetRange("Buy-from Vendor No.", "Vendor No.");
                    PurchaseOrders.SetRange(Status, PurchaseOrders.Status::Released);
                    PurchaseOrders.SetRange("Completely Received", false);


                    PurchaseOrders."No." := "Order Reference";
                    If Page.RunModal(PAGE::"Purchase Order List", PurchaseOrders, "No.") = Action::LookupOK then
                        exit(PurchaseOrders."No.");

                end;



        end;


    end;

}