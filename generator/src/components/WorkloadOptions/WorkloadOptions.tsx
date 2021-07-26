import {
  Checkbox,
  IStackItemStyles,
  IStackStyles,
  IStackTokens,
  Stack,
  StackItem
} from '@fluentui/react';
import * as React from 'react';
import { useRecoilValue } from 'recoil';
import { Resource } from '../../models/Resource';
import { Workload } from '../../models/Workload';
import { selectedResourcesState } from '../../state/resourcesState';
import { workloadsState } from '../../state/workloadState';
import { ContentCard } from '../ContentCard/ContentCard';

export interface IWorkloadOptionsProps {
  onSelectedResourcesChange: (changedResource: Resource, checked?: boolean) => void;
}

export const WorkloadOptions: React.FunctionComponent<IWorkloadOptionsProps> = (props) => {
  const workloads = useRecoilValue(workloadsState);
  const resources = useRecoilValue(selectedResourcesState);

  const wrapStackTokens: IStackTokens = { childrenGap: 30 };

  const stackStyles: IStackStyles = {
    root: {
      width: '100%',
    },
  };

  const stackItemStyles: IStackItemStyles = {
    root: {
      width: 275,
    },
  };

  const _onCheckboxMouseEnter = function (resource: Resource) {
    resource.hovered = true;
    props.onSelectedResourcesChange(resource, false);
  };

  return (
    <>
      {workloads?.map((workload: Workload) => (
        <ContentCard title={workload.title} iconName={workload.iconName}>
          <Stack horizontal wrap styles={stackStyles} tokens={wrapStackTokens}>
            {resources
              ?.filter((resource) => resource.workload === workload.key)
              .map((resource: Resource) => (
                <StackItem styles={stackItemStyles}>
                  <Checkbox
                    id={resource.name}
                    label={resource.name}
                    checked={resource.checked}
                    onChange={(ev, checked) => props.onSelectedResourcesChange(resource, checked)}
                    value={resource.name}
                    key={resource.name}
                    onMouseOver={() => _onCheckboxMouseEnter(resource)}
                  />
                </StackItem>
              ))}
          </Stack>
        </ContentCard>
      ))}
    </>
  );
};
