tableextension 50120 "TFB Sales Line" extends "Sales Line" //37
{
    fields
    {
        field(50121; "TFB Price Unit Cost"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Per Kg Price';
            DecimalPlaces = 2 :;

            trigger OnValidate()

            begin
                UpdateUnitPrice();
            end;
        }
        field(50124; "TFB Price Unit"; Enum "TFB Price Unit")
        {
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'No Longer required';

            Caption = 'Pricing Unit';

            trigger OnValidate()

            begin
                UpdateUnitPrice();
            End;

        }
        field(50122; "TFB Customer Name"; Text[100])
        {

            Caption = 'Sell-to Customer Name';
            FieldClass = FlowField;
            CalcFormula = lookup("Sales Header"."Sell-to Customer Name" where("Sell-to Customer No." = FIELD("Sell-to Customer No.")));
            Editable = false;


        }
        field(50123; "TFB Line Total Weight"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Line Weight';
            DecimalPlaces = 2;
            Editable = false;
            BlankZero = true;


        }

        field(50125; "TFB Buy-from Vendor No."; Code[20])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Purchase Header"."Buy-from Vendor No." where("No." = field("Purchase Order No.")));
            Editable = false;

        }

        field(50400; "TFB CoA Sent"; Boolean)
        {
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Use dynamic check to see if document has been sent';
            Caption = 'CoA Sent';
            Editable = False;
        }
        field(50126; "TFB Pre-Order"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Pre-Order';
            Editable = true;

            trigger OnValidate()

            var

            begin
                If "TFB Pre-Order" = true and "TFB Pre-Order" <> xRec."TFB Pre-Order" then
                    SetPreOrderExchRate();
            end;

        }
        field(50127; "TFB Pre-Order Currency"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Pre-Order Currency';
            Editable = false;

        }
        field(50128; "TFB Pre-Order Exch. Rate"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Pre-Order Exch. Rate';
            Editable = false;
        }
        field(50129; "TFB Pre-Order Eff. Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Pre-Order Eff. Date';
            Editable = false;
        }

        field(50130; "TFB Document Date"; Date)
        {
            FieldClass = FlowField;
            Caption = 'Document Date';
            CalcFormula = lookup("Sales Header"."Document Date" where("No." = field("Document No."), "Document Type" = field("Document Type")));
        }

        field(50132; "TFB Document Status"; Enum "Sales Document Status")
        {
            FieldClass = FlowField;
            Caption = 'Status';
            CalcFormula = lookup("Sales Header".Status where("No." = field("Document No."), "Document Type" = field("Document Type")));
        }

        field(50134; "TFB External Document No."; Text[35])
        {
            FieldClass = FlowField;
            Caption = 'External Document No.';
            CalcFormula = lookup("Sales Header"."External Document No." where("No." = field("Document No."), "Document Type" = field("Document Type")));
        }

        field(50140; "TFB Pre-Order Adj. Exch. Rate"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Pre-Order Adj. Exch. Rate';
            Editable = false;
        }
        field(50142; "TFB Pre-Order Unit Price Adj."; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Pre-Order Unit Price Adj.';
            Editable = false;
        }
        field(50146; "TFB Pre-Order Adj. Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Pre-Order Adj. Date';
            Editable = false;
        }

        field(50148; "TFB Price Unit Discount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Per Kg Discount';
            DecimalPlaces = 2 :;

            trigger OnValidate()

            begin
                UpdateLineDiscount();
            end;
        }
        field(50150; "TFB No. Of Comments"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = Count("Sales Comment Line" where("No." = field("Document No."), "Document Type" = field("Document Type"), "Document Line No." = field("Line No.")));
        }


        modify("Unit of Measure Code")
        {
            trigger OnAfterValidate()

            begin
                UpdatePriceUnitPrice();
                UpdateLineTotal();

            end;
        }


        modify(Quantity)
        {
            trigger OnAfterValidate()

            begin
                UpdateLineTotal();
            end;
        }

        modify("Unit Price")
        {
            trigger OnAfterValidate()

            begin
                UpdatePriceUnitPrice();
                UpdateLineTotal();
            end;
        }
    }

    fieldgroups
    {
        addlast(Brick; Quantity, "TFB Customer Name", "Planned Shipment Date")
        { }
    }

    local procedure UpdateLineTotal()

    begin
        If Type = Type::Item then
            Rec."TFB Line Total Weight" := TFBPricingLogic.CalcLineTotalKg(rec."Net Weight", rec."Quantity (Base)")
        else
            Rec."TFB Line Total Weight" := 0;
    end;

    local procedure UpdateUnitPrice()

    begin
        If Type = Type::Item then begin
            PriceUnit := PriceUnit::KG;
            Rec.Validate("Unit Price", TFBPricingLogic.CalculateUnitPriceByPriceUnit(rec."No.", rec."Unit of Measure Code", PriceUnit, rec."TFB Price Unit Cost"));
        end;
    end;

    local procedure UpdatePriceUnitPrice()

    begin
        If Type = Type::Item then begin
            PriceUnit := PriceUnit::KG;
            "TFB Price Unit Cost" := TFBPricingLogic.CalculatePriceUnitByUnitPrice(rec."No.", rec."Unit of Measure Code", PriceUnit, rec."Unit Price");
        end;
    end;

    local procedure SetPreOrderExchRate()

    var
        ExchangeRate: Record "Currency Exchange Rate";
        Header: Record "Sales Header";
        CompanyInfo: Record "Company Information";
        Item: Record Item;
        Vendor: Record Vendor;
        Date: Date;
        Rate: Decimal;


    begin
        CompanyInfo.Get();
        Header.SetRange("No.", "Document No.");
        Header.SetRange("Document Type", "Document Type");
        Header.FindFirst();

        If Item.Get("No.") then
            If Vendor.Get(Item."Vendor No.") then
                If Vendor."Currency Code" <> '' then begin
                    ExchangeRate.GetLastestExchangeRate(Vendor."Currency Code", Date, Rate);
                    Rate := ExchangeRate.ExchangeRate(Header."Order Date", Vendor."Currency Code");

                end;

        If Rate > 0 then begin
            "TFB Pre-Order Currency" := Vendor."Currency Code";
            "TFB Pre-Order Exch. Rate" := Rate;
            "TFB Pre-Order Eff. Date" := Header."Order Date";
        end
        else begin
            "TFB Pre-Order Currency" := CompanyInfo."Country/Region Code";
            "TFB Pre-Order Exch. Rate" := 1;
            "TFB Pre-Order Eff. Date" := Header."Order Date";
        end;
    end;

    local procedure UpdateLineDiscount()
    begin
        Rec.Validate(Rec."Line Discount Amount", Rec."Net Weight" * Rec.Quantity * Rec."TFB Price Unit Discount");
    end;

    var

        TFBPricingLogic: Codeunit "TFB Pricing Calculations";
        PriceUnit: Enum "TFB Price Unit";
}