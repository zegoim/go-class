package debugUtil

import (
	"context"
	"testing"
	"time"
)

func TestCostTime(t *testing.T) {
	ctx := context.WithValue(context.Background(), "unique_id", "160448905143484961")
	defer LogFuncTimeCost(ctx)()

	time.Sleep(100 * time.Millisecond)
}
