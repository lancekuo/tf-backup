package main

import (
	"fmt"
	"strconv"
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
	svc := ec2.New(cfg)
	params := &ec2.DescribeInstancesInput{
		Filters: []ec2.Filter{
			{
				Name: aws.String("tag:Retention"),
				Values: []string{
					strings.Join([]string{"*"}, ""),
				},
			},
		},
	}

	req := svc.DescribeInstancesRequest(params)
	resp, err := req.Send()
	if err != nil {
		fmt.Print("Failed to describe instance, permission error?: " + err.Error())
	}
	// Looking for the right EBS device in BlockDeviceMappings
	if len(resp.Reservations) > 0 {
		for _, Reservation := range resp.Reservations {
			for _, instance := range Reservation.Instances {
				for _, ebs := range instance.BlockDeviceMappings {
					devicename := *ebs.DeviceName
					if strings.Index(devicename, "xvd") != -1 {
						var description *string
						retention := aws.String("7")
						for _, tag := range instance.Tags {
							if strings.Index(*tag.Key, "Name") != -1 {
								description = tag.Value
							}
							if strings.Index(*tag.Key, "Retention") != -1 {
								retention = tag.Value
							}
						}
						tmp, _ := strconv.Atoi(*retention)
						deleteon := time.Now().AddDate(0, 0, tmp)
						volumeId := ebs.Ebs.VolumeId
						// Creating the snapshot for the EBS
						params := &ec2.CreateSnapshotInput{
							VolumeId:    volumeId,
							Description: aws.String("EBS Daily backup"),
							TagSpecifications: []ec2.TagSpecification{
								{
									ResourceType: "snapshot",
									Tags: []ec2.Tag{
										{
											Key:   aws.String("Name"),
											Value: description,
										},
										{
											Key:   aws.String("DeleteOn"),
											Value: aws.String(deleteon.Format("2006-01-02")),
										},
										{
											Key:   aws.String("Type"),
											Value: aws.String("Automated"),
										},
									},
								},
							},
						}
						req := svc.CreateSnapshotRequest(params)
						_, err := req.Send()
						if err != nil {
							fmt.Print("Failed to create snapshot for " + *description + ":" + err.Error())
						}

						fmt.Printf("Created snapshot for %s and tagged as it should be deleted on %s\n", *description, deleteon.Format("2006-01-02"))
					}
				}
			}
		}
	}
	return len(resp.Reservations), nil
}
func main() {
	lambda.Start(LambdaHandler)
}
