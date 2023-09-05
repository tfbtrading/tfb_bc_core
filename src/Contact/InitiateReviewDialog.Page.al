page 50179 "TFB Initiate Review Dialog"
{
    PageType = StandardDialog;
    UsageCategory = Administration;
    ApplicationArea = All;
    Caption = 'Initiative Review';

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(FinishReview; _FinishReview)
                {
                    Caption = 'Complete review now';
                    ToolTip = 'Specifies if the review should be completed immediately';

                    trigger OnValidate()

                    begin
                        if _FinishReview then
                            _ReviewDate := today;
                    end;
                }

                group(dateDetails)
                {
                    ShowCaption = false;
                    Visible = not _FinishReview;

                    field(ReviewDate; _ReviewDate)
                    {
                        Caption = 'Target review completion by';
                        ToolTip = 'Specify when you want the review to finish by';
                    }
                }
            }
        }
    }

    actions
    {

    }

    var
        _ReviewDate: Date;
        _FinishReview: Boolean;

    procedure SetDefaults(pReviewDate: Date; pFinishReview: Boolean)

    begin

        _ReviewDate := pReviewDate;
        _FinishReview := pFinishReview;

    end;

    procedure getExpectedReviewDate(): Date

    begin
        exit(_ReviewDate);
    end;

    procedure getShouldCompleteNow(): Boolean

    begin
        exit(_FinishReview);
    end;
}