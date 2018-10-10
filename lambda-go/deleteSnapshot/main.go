package main

import (
	"fmt"
	"strings"
	"time"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/aws/endpoints"
	"github.com/aws/aws-sdk-go-v2/aws/external"
	"github.com/aws/aws-sdk-go-v2/service/ec2"
)

func LambdaHandler() (int, error) {
	cfg, err := external.LoadDefaultAWSConfig()
	if err != nil {
		panic("PANICCCCCCCCCC" + err.Error())
	}
	cfg.Region = endpoints.CaCentral1RegionID
	// Looking for Instances
	deleteon := time.Now().Format("2006-01-02")
	svc := ec2.New(cfg)
	params := &ec2.DescribeSnapshotsInput{
		Filters: []ec2.Filter{
			{
				Name: aws.String("tag:DeleteOn"),
				Values: []string{
					strings.Join([]string{deleteon}, ""),
				},
			},
			{
				Name: aws.String("tag:Type"),
				Values: []string{
					strings.Join([]string{"Automated"}, ""),
				},
			},
		},
	}

	req := svc.DescribeSnapshotsRequest(params)
	resp, err := req.Send()
	if err != nil {
		fmt.Print("Failed to list snapshots, permission error?: " + err.Error())
	}
	// Looking for the right EBS device in BlockDeviceMappings
	if len(resp.Snapshots) > 0 {
		fmt.Printf("Found %d snapshots that need deleting on %s\n", len(resp.Snapshots), deleteon)
		for _, Snapshot := range resp.Snapshots {
			params := &ec2.DeleteSnapshotInput{
				SnapshotId: Snapshot.SnapshotId,
			}
			req := svc.DeleteSnapshotRequest(params)
			_, err := req.Send()
			if err != nil {
				fmt.Print("Failed to delete snapshot for " + *Snapshot.SnapshotId + ":" + err.Error())
			}

			fmt.Printf("Deleted snapshot %s for on %s.\n", *Snapshot.SnapshotId, deleteon)
		}
	} else {
		fmt.Printf("==============> There is no snapshot needs to be deleted today (%s)! Awesome!", deleteon)
	}
	return len(resp.Snapshots), nil
}

func main() {
	lambda.Start(LambdaHandler)
}
