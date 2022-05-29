page 50335 "TFB ItemCosting Entity"
{
    PageType = API;
    caption = 'itemCosting';
    APIPublisher = 'tfb';
    APIVersion = 'v2.0';
    APIGroup = 'costings';
    EntityName = 'itemCosting';
    EntitySetName = 'itemCostings';
    DelayedInsert = True;
    SourceTable = "TFB Item Costing";
    Editable = false;
    ODataKeyFields = SystemId;


    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'id';
                    ApplicationArea = All;
                }
                field(itemNo; Rec."Item No.")
                {
                    Caption = 'itemNo';
                    ApplicationArea = All;
                }
                field(description; Rec."Description")
                {

                    Caption = 'description';
                    ApplicationArea = All;
                }
                field(costingType; Rec."Costing Type")
                {

                    Caption = 'costingType';
                    ApplicationArea = All;
                }
                field(effectiveDate; Rec."Effective Date")
                {

                    Caption = 'effectiveDate';
                    ApplicationArea = All;
                }
                field(purchasePriceUnit; Rec."Purchase Price Unit")
                {

                    Caption = 'purchasePriceUnit';
                    ApplicationArea = All;
                }
                field(avgCost; Rec."Average Cost")
                {

                    Caption = 'iavgCost';
                    ApplicationArea = All;
                }
                field(mktPrice; Rec."Market Price")
                {

                    Caption = 'mktPrice';
                    ApplicationArea = All;

                }
                field(pricingMargin; Rec."Pricing Margin %")
                {

                    Caption = 'pricingMargin';
                    ApplicationArea = All;

                }

                field(marketPricingMargin; Rec."Market Price Margin %")
                {

                    Caption = 'marketPricingMargin';
                    ApplicationArea = All;

                }
                field(lastModified; Rec."Last Modified Date Time")
                {
                    Caption = 'lastModified';
                    ApplicationArea = All;
                }
                field("hasLines"; Rec."HasLines")
                {
                    Caption = 'hasLines';
                    ApplicationArea = All;

                }
                field(exwUnitPrice; Rec."Exw Unit")
                {
                    Caption = 'exwUnitPrice';
                    ApplicationArea = All;

                }
                field(exwKgPrice; Rec."Exw Kg")
                {
                    Caption = 'exwKgPrice';
                    ApplicationArea = All;

                }
                field(melMetroUnitPrice; Rec."Mel Metro Unit")
                {
                    Caption = 'elMetroUnitPrice';
                    ApplicationArea = All;



                }
                field(melMetroKgPrice; Rec."Mel Metro Kg")
                {
                    Caption = 'melMetroKgPrice';
                    ApplicationArea = All;
                }
                field(sydMetroUnitPrice; Rec."Syd Metro Unit")
                {
                    Caption = 'sydMetroUnitPrice';
                    ApplicationArea = All;
                }
                field(sydMetroKgPrice; Rec."Adl Metro Unit")
                {
                    Caption = 'sydMetroKgPrice';
                    ApplicationArea = All;
                }
                field(brsMetroUnitPrice; Rec."Brs Metro Unit")
                {
                    Caption = 'brsMetroUnitPric';
                    ApplicationArea = All;
                }
                field(brsMetroKgPrice; Rec."Brs Metro Kg")
                {
                    Caption = 'brsMetroKgPrice';
                    ApplicationArea = All;
                }

            }
        }

    }


    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec.Insert(true);

        Rec.Modify(true);
        exit(false);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        Rec.Delete(true);

        exit(false);
    end;


}